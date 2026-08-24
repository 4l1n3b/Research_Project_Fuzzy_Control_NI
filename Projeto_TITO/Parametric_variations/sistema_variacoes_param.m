%variacoes parametricas intervalo(0.95, 1.05)
ganho = 0.1;
K = [2.89 -3.1 -4.22 22.222];
tau = [550 260 546 180];
Td = [55 51 91 16];
qtde_amostras = 900;

% Sao gerados quadro valores radomicos para emular variacoes parametricas
% no sistema

% k11 = K(1)*(0.90 + 0.20*rand(2,1));
% k12 = K(2)*(0.90 + 0.20*rand(2,1));
% k21 = K(3)*(0.90 + 0.20*rand(2,1));
% k22 = K(4)*(0.90 + 0.20*rand(2,1));
% 
% tau11 = tau(1)*(0.90 + 0.20*rand(2,1));
% tau12 = tau(2)*(0.90 + 0.20*rand(2,1));
% tau21 = tau(3)*(0.90 + 0.20*rand(2,1));
% tau22 = tau(4)*(0.90 + 0.20*rand(2,1));
% 
% Td11v = round(Td(1)*(0.90 + 0.20*rand(2,1)));
% Td12v = round(Td(2)*(0.90 + 0.20*rand(2,1)));
% Td21v = round(Td(3)*(0.90 + 0.20*rand(2,1)));
% Td22v = round(Td(4)*(0.90 + 0.20*rand(2,1)));

% Ganho estático
k11v = [2.804;
         3.144];

k12v = [-3.333;
         -3.131];

k21v = [-4.323;
         -4.293];

k22v = [20.923;
         21.339];

% Constante de tempo
tau11v = [546.802;
          520.354];

tau12v = [277.904;
          244.128];

tau21v = [516.071;
          510.041];

tau22v = [170.196;
          177.685];

%Atraso de transporte
Td11v = [53;60];
Td12v = [50;48];
Td21v = [98;100];
Td22v = [16;15];

%vetores para contabiliar as amostras de atraso de transporte
am_Td11 = [3,4];
am_Td12 = [3,3];
am_Td21 = [6,6];
am_Td22 = [1,1];

% Pré-alocação 
num_mat = cell(2, 2); % Armazena num11, num12, num21, num22 para cada iteração
den_mat = cell(2, 2); % Armazena den11, den12, den21, den22 para cada iteração

%Loop para gerar a funcao de transferencia e discretia-las
for i=1:2
Gs_11 = tf([k11v(i)], [tau11v(i) 1],'InputDelay',Td11v(i));
Gs_12 = tf([k12v(i)*ganho], [tau12v(i) 1],'InputDelay',Td12v(i));
Gs_21 = tf([k21v(i)], [tau21v(i) 1],'InputDelay',Td21v(i));
Gs_22 = tf([k22v(i)*ganho], [tau22v(i) 1],'InputDelay',Td22v(i));
T_amost = 18;
Gz_11 = c2d(Gs_11, T_amost, 'zoh')
Gz_12 = c2d(Gs_12, T_amost, 'zoh')
Gz_21 = c2d(Gs_21, T_amost, 'zoh')
Gz_22 = c2d(Gs_22, T_amost, 'zoh')

% Extração e armazenamento nas Matrizes de Células
[num_mat{i,1}, den_mat{i,1}] = tfdata(Gz_11, 'v');
[num_mat{i,2}, den_mat{i,2}] = tfdata(Gz_12, 'v');
[num_mat{i,3}, den_mat{i,3}] = tfdata(Gz_21, 'v');
[num_mat{i,4}, den_mat{i,4}] = tfdata(Gz_22, 'v');

end

 
y_1mft_inicial = 22;
y_2mfu_inicial = 50;
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras); y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras); y_22u = zeros(1, qtde_amostras);
y_1t  = zeros(1, qtde_amostras); y_2u  = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras); erro2 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);

for k = 1:7 
    r_1t(k) = 30;
    r_2u(k) = 50;
    y_1t(k) = y_1mft_inicial;
    y_2u(k) = y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = (k) * T_amost;
end

%% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t(8:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(8:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;


for i = 1:3
    %% 1. EXTRAÇÃO DOS DADOS DA MATRIZ (CELL ARRAY)
    % Acessa os coeficientes da variação paramétrica 'i'
    if i ~= 3
    n11 = num_mat{i,1}; d11 = den_mat{i,1};
    n12 = num_mat{i,2}; d12 = den_mat{i,2};
    n21 = num_mat{i,3}; d21 = den_mat{i,3};
    n22 = num_mat{i,4}; d22 = den_mat{i,4};
    cont = am_Td21(i)+2;
    else
    cont = 8;    
    end
    %% 3. LOOP DE SIMULAÇÃO
    for k = cont:qtde_amostras 
        % Bloco 11: r1 -> y1
        if i == 3
            y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
            y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * erro2(k-3) - 0.01718 * erro2(k-4);
            y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
            y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * erro2(k-1) + 0.1869 * erro2(k-2);
               
        else
        % Usamos d11(2) pois d11(1) é sempre 1. 
        % n11(end-1) e n11(end) garantem o acesso aos coeficientes ativos.
        y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*erro1(k-am_Td11(i)) + n11(2)*erro1(k-am_Td11(i)-1);
        
        % Bloco 12: r2 -> y1
        y_12u(k) = -d12(2)*y_12u(k-1) + n12(1)*erro2(k-am_Td12(i)) + n12(2)*erro2(k-am_Td12(i)-1);
        
        % Bloco 21: r1 -> y2
        y_21t(k) = -d21(2)*y_21t(k-1) + n21(1)*erro1(k-am_Td21(i)) + n21(2)*erro1(k-am_Td21(i)-1);
        
        % Bloco 22: r2 -> y2
        y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*erro2(k-am_Td22(i)) + n22(2)*erro2(k-am_Td22(i)-1);
        end
        % Saídas Totais (Soma das parcelas + Condição Inicial)
        y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
        y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
        
        % Cálculo do Erro
        erro1(k) = r_1t(k) - y_1t(k);
        erro2(k) = r_2u(k) - y_2u(k);
        tempo(k) = k * T_amost;
    end

    %% 4. SALVAR DADOS 
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});

    switch i
        case 1
            filename = 'Tables/incubadora_var_param1.csv';
        case 2
            filename = 'Tables/incubadora_var_param2.csv';
        otherwise
            filename = 'Tables/incubadora_var_param100.csv';
    end
    
    %Verifica se o diretório existe antes de salvar
    if ~exist('Tables', 'dir'), mkdir('Tables'); end
    
    writetable(T, filename);
fprintf('Arquivo %s salvo\n', filename);

end
