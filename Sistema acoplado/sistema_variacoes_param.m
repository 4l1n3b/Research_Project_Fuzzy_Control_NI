%variacoes parametricas intervalo(0.95, 1.05)
ganho = 0.1;
K = [2.89 -3.1 -4.22 22.222];
tau = [550 260 546 180];
qtde_amostras = 600;
% Sao gerados quadro valores radomicos para emular variacoes parametricas
% no sistema

% k11 = K(1)*0.95 + (1.05*K(1)-K(1)*0.95).*rand(4,1)
% k12 = K(2)*0.95 + (1.05*K(2)-K(2)*0.95).*rand(4,1)
% k21 = K(3)*0.95 + (1.05*K(3)-K(3)*0.95).*rand(4,1)
% k22 = K(4)*0.95 + (1.05*K(4)-K(4)*0.95).*rand(4,1)
% 
% tau11 = tau(1)*0.95 + (1.05*tau(1)-tau(1)*0.95).*rand(4,1)
% tau12 = tau(2)*0.95 + (1.05*tau(2)-tau(2)*0.95).*rand(4,1)
% tau21 = tau(3)*0.95 + (1.05*tau(3)-tau(3)*0.95).*rand(4,1)
% tau22 = tau(4)*0.95 + (1.05*tau(4)-tau(4)*0.95).*rand(4,1)

k11 = [2.981;3.007;2.782;3.009];
k12 = [-3.141;-2.975;-3.031;-3.114];
k21 = [-4.413;-4.416;-4.076;-4.419];
k22 = [23.24;22.19;22.89;21.43];

tau11 = [545.70;572.86;566.07;575.27];
tau12 = [264.05;247.93;269.08;271.28];
tau21 = [555.76;560.07;559.28;540.12];
tau22 = [182.80;174.08;183.71;171.57];

% Pré-alocação usando Cell Arrays (melhor para tamanhos variáveis de coeficientes)
num_mat = cell(4, 4); % Armazena num11, num12, num21, num22 para cada iteração
den_mat = cell(4, 4); % Armazena den11, den12, den21, den22 para cada iteração

%Loop para gerar a funcao de transferencia e discretia-las
for i=1:4
Gs_11 = tf([k11(i)], [tau11(i) 1],'InputDelay',55);
Gs_12 = tf([k12(i)*ganho], [tau12(i) 1],'InputDelay',51);
Gs_21 = tf([k21(i)], [tau21(i) 1],'InputDelay',91);
Gs_22 = tf([k22(i)*ganho], [tau22(i) 1],'InputDelay',16);
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


for i = 1:4
    %% 1. EXTRAÇÃO DOS DADOS DA MATRIZ (CELL ARRAY)
    % Acessa os coeficientes da variação paramétrica 'i'
    n11 = num_mat{i,1}; d11 = den_mat{i,1};
    n12 = num_mat{i,2}; d12 = den_mat{i,2};
    n21 = num_mat{i,3}; d21 = den_mat{i,3};
    n22 = num_mat{i,4}; d22 = den_mat{i,4};

    %% 3. LOOP DE SIMULAÇÃO
    for k = 8:qtde_amostras 
        % Bloco 11: r1 -> y1
        % Usamos d11(2) pois d11(1) é sempre 1. 
        % n11(end-1) e n11(end) garantem o acesso aos coeficientes ativos.
        y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*erro1(k-4) + n11(2)*erro1(k-5);
        
        % Bloco 12: r2 -> y1
        y_12u(k) = -d12(2)*y_12u(k-1) + n12(1)*erro2(k-3) + n12(2)*erro2(k-4);
        
        % Bloco 21: r1 -> y2
        y_21t(k) = -d21(2)*y_21t(k-1) + n21(1)*erro1(k-6) + n21(2)*erro1(k-7);
        
        % Bloco 22: r2 -> y2
        y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*erro2(k-1) + n22(2)*erro2(k-2);
        
        % Saídas Totais (Soma das parcelas + Condição Inicial)
        y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
        y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
        
        % Cálculo do Erro
        erro1(k) = r_1t(k) - y_1t(k);
        erro2(k) = r_2u(k) - y_2u(k);
        tempo(k) = k * T_amost;
    end

    %% 4. SALVAR DADOS (Mantendo seu bloco Switch/Case)
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});

    switch i
        case 1
            filename = 'Tables/incubadora_var_param1.csv';
        case 2
            filename = 'Tables/incubadora_var_param2.csv';
        case 3 
            filename = 'Tables/incubadora_var_param3.csv';
        otherwise
            filename = 'Tables/incubadora_var_param4.csv';
    end
    
    % % Verifica se o diretório existe antes de salvar
    % if ~exist('Tables', 'dir'), mkdir('Tables'); end
    
    writetable(T, filename);
end
% 
% %discretixacao 
% % o loop de malha fechada