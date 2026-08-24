%% 1. CONFIGURAÇÕES E PARÂMETROS DAS PLANTAS (VARIAÇÕES)
ganho = 1;
K = [2.89 -3.1 -4.22 22.222];
tau = [550 260 546 180];
T_amostra = 18;
qtde_amostras = 900;

% Vetores de variações paramétricas fornecidos
% k11_v = [2.981; 3.007; 2.782; 3.009];
% k12_v = [-3.141; -2.975; -3.031; -3.114];
% k21_v = [-4.413; -4.416; -4.076; -4.419];
% k22_v = [23.24; 22.19; 22.89; 21.43];
% tau11_v = [545.70; 572.86; 566.07; 575.27];
% tau12_v = [264.05; 247.93; 269.08; 271.28];
% tau21_v = [555.76; 560.07; 559.28; 540.12];
% tau22_v = [182.80; 174.08; 183.71; 171.57];
%K
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
Gz_11 = c2d(Gs_11, T_amost, 'zoh');
Gz_12 = c2d(Gs_12, T_amost, 'zoh');
Gz_21 = c2d(Gs_21, T_amost, 'zoh');
Gz_22 = c2d(Gs_22, T_amost, 'zoh');

% Extração e armazenamento nas Matrizes de Células
[num_mat{i,1}, den_mat{i,1}] = tfdata(Gz_11, 'v');
[num_mat{i,2}, den_mat{i,2}] = tfdata(Gz_12, 'v');
[num_mat{i,3}, den_mat{i,3}] = tfdata(Gz_21, 'v');
[num_mat{i,4}, den_mat{i,4}] = tfdata(Gz_22, 'v');

end

%% 2. PARÂMETROS DO CONTROLADOR PID (ZIEGLER-NICHOLS)
% Temperatura
%### Ziegler_nichols Frequencial

%temperatura

Kp_t = 2.67;

Ki_t = 0.0279;

Kd_t = 78.2730;
g0_t = Kp_t + ((Ki_t*T_amostra)/2) + (Kd_t/T_amostra);
g1_t = ((Ki_t*T_amostra)/2) - Kp_t - ((2*Kd_t)/T_amostra);
g2_t = Kd_t/T_amostra;

% Umidade
Kp_u = 0.25;

Ki_u = 0.0067;

Kd_u = 3.3817;
g0_u = Kp_u + ((Ki_u*T_amostra)/2) + (Kd_u/T_amostra);
g1_u = ((Ki_u*T_amostra)/2) - Kp_u - ((2*Kd_u)/T_amostra);
g2_u = Kd_u/T_amostra;
% amostras = [500 1000 1500 2000 2500 3000];
amostras = [300 600 900];
%% 3. LOOP DE SIMULAÇÃO PARA CADA CASO PARAMÉTRICO
for i = 1:3
    % Reinicialização de variáveis
    u_1t = zeros(1, qtde_amostras); u_2u = zeros(1, qtde_amostras);
    y_11t = zeros(1, qtde_amostras); y_12u = zeros(1, qtde_amostras);
    y_21t = zeros(1, qtde_amostras); y_22u = zeros(1, qtde_amostras);
    y_1t = zeros(1, qtde_amostras); y_2u = zeros(1, qtde_amostras);
    erro1 = zeros(1, qtde_amostras); erro2 = zeros(1, qtde_amostras);
    r_1t = zeros(1, qtde_amostras); r_2u = zeros(1, qtde_amostras);
    tempo = zeros(1, qtde_amostras);
    
    y_1t_inicial = 22; y_2u_inicial = 50;

    % % Coeficientes da planta atual (Cenário i)
    % n11 = num_mat{i,1}; d11 = den_mat{i,1};
    % n12 = num_mat{i,2}; d12 = den_mat{i,2};
    % n21 = num_mat{i,3}; d21 = den_mat{i,3};
    % n22 = num_mat{i,4}; d22 = den_mat{i,4};
    % soma_erro1 = 0;
    % soma_erro2 = 0;
    % soma_erro1_pond = 0;
    % soma_erro2_pond = 0;
    % Condições iniciais (1 a 7)
    for k = 1:7
        r_1t(k) = 30; r_2u(k) = 55;
        y_1t(k) = y_1t_inicial; y_2u(k) = y_2u_inicial;
        erro1(k) = r_1t(k) - y_1t(k); erro2(k) = r_2u(k) - y_2u(k);
        tempo(k) = k * T_amostra;
        % soma_erro1 = soma_erro1 + abs(erro1(k));
        % soma_erro2 = soma_erro2 + abs(erro2(k));
        % soma_erro1_pond = soma_erro1_pond + tempo(k)*abs(erro1(k));
        % soma_erro2_pond = soma_erro2_pond + tempo(k)*abs(erro2(k));
    end
    
    % Definição dos patamares de referência
    r_1t(8:amostras(1)) = 30; 
    r_1t((amostras(1)+1):(amostras(2))) = 36; 
    r_1t((amostras(2)+1):amostras(3)) = 36;
    % r_1t((amostras(3)+1):amostras(4)) = 37.5;
    % r_1t((amostras(4)+1):amostras(5)) = 37.5;
    % r_1t((amostras(5)+1):amostras(6)) = 37.5;
    r_2u(8:amostras(1)) = 55; 
    r_2u((amostras(1)+1):(amostras(2))) = 55; 
    r_2u((amostras(2)+1):amostras(3)) = 65;
    % r_2u((amostras(3)+1):amostras(4)) = 60;
    % r_2u((amostras(4)+1):amostras(5)) = 65;
    % r_2u((amostras(5)+1):amostras(6)) = 65;
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
            y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
            y_12u(k) = 0.9331 * y_12u(k-1) - 0.03556 * u_2u(k-3) - 0.1718 * u_2u(k-4);
            y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
            y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);

               
        else
        % Usamos d11(2) pois d11(1) é sempre 1. 
        % n11(end-1) e n11(end) garantem o acesso aos coeficientes ativos.
        y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*u_1t(k-am_Td11(i)) + n11(2)*u_1t(k-am_Td11(i)-1);
        
        % Bloco 12: r2 -> y1
        y_12u(k) = -d12(2)*y_12u(k-1) + n12(1)*u_2u(k-am_Td12(i)) + n12(2)*u_2u(k-am_Td12(i)-1);
        
        % Bloco 21: r1 -> y2
        y_21t(k) = -d21(2)*y_21t(k-1) + n21(1)*u_1t(k-am_Td21(i)) + n21(2)*u_1t(k-am_Td21(i)-1);
        
        % Bloco 22: r2 -> y2
        y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*u_2u(k-am_Td22(i)) + n22(2)*u_2u(k-am_Td22(i)-1);
        end
        % Saída Combinada
        y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
        y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;

        % Erro
        erro1(k) = r_1t(k) - y_1t(k);
        erro2(k) = r_2u(k) - y_2u(k);
        
        % Cálculo do PID (Sinal de Controle)
        u_1t(k) = u_1t(k-1) + g0_t*erro1(k) + g1_t*erro1(k-1) + g2_t*erro1(k-2);
        u_2u(k) = u_2u(k-1) + g0_u*erro2(k) + g1_u*erro2(k-1) + g2_u*erro2(k-2);

        % Saturação
        if u_1t(k) > 100, u_1t(k) = 100; elseif u_1t(k) < 0, u_1t(k) = 0; end
        if u_2u(k) > 100, u_2u(k) = 100; elseif u_2u(k) < 0, u_2u(k) = 0; end
        
        tempo(k) = k * T_amostra;
        
        % % Acumula o erro apenas para o caso i=3 e até o fim do 1º patamar de umidade
        % if i == 3 && k <= amostras(2)
        %     soma_erro2 = soma_erro2 + abs(erro2(k));
        %     soma_erro2_pond = soma_erro2_pond + tempo(k) * abs(erro2(k));
        % end
    end

    %% 4. SALVAR DADOS (Mantendo sua estrutura Switch/Case)
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', ...
        'Saida_Umidade', 'Controle_Temperatura', 'Controle_Umidade', 'Erro_Temperatura', 'Erro_Umidade'});

        switch i
            case 1
                filename = 'Tables/ZN_var_paramTEST/incubadora_var_param1ZN.csv';
            case 2
                filename = 'Tables/ZN_var_paramTEST/incubadora_var_param2ZN.csv';
            otherwise
                filename = 'Tables/ZN_var_paramTEST/incubadora_var_param100ZN.csv';
        end

        if ~exist('Tables', 'dir'), mkdir('Tables'); end
        writetable(T, filename);
        disp(['Arquivo salvo: ' filename]);
end
   