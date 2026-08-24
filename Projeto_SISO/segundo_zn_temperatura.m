%==========================================================================
% CONTROLADOR PID (2º MÉTODO DE ZIEGLER-NICHOLS) - TEMPERATURA DESACOPLADA
%==========================================================================
clear; clc;

%% PARÂMETROS DA SIMULAÇÃO E DISCRETIZAÇÃO
qde_amostras = 900;
T_amostra = 18; % Período de amostragem em segundos

% Ganho estático (Temperatura desacoplada)
k11v = [2.804; 3.144];

% Constante de tempo
tau11v = [546.802; 520.354];

% Atraso de transporte (s) e em amostras
Td11v = [53; 60];
am_Td11 = [3, 4];

% Pré-alocação dos modelos discretos
num_mat = cell(2, 1);
den_mat = cell(2, 1);

for idx = 1:2
    Gs_11 = tf([k11v(idx)], [tau11v(idx) 1], 'InputDelay', Td11v(idx));
    Gz_11 = c2d(Gs_11, T_amostra, 'zoh');
    [num_mat{idx,1}, den_mat{idx,1}] = tfdata(Gz_11, 'v');
end

%% SINTONIA DO PID (ZIEGLER-NICHOLS - 2º MÉTODO / FREQUÊNCIA CRÍTICA)
Kcr = 4.876;
Pcr = 3.9 * 60; % Período crítico em segundos

Kp = 0.6 * Kcr
Kp = 2.95
Ti = 0.5 * Pcr;
Td = 0.125 * Pcr;

% Equação de Diferenças via Discretização Trapezoidal (Tustin)
g0 = Kp * (1 + (Td / T_amostra) + (T_amostra / Ti));
g1 = -Kp * (1 + 2 * (Td / T_amostra));
g2 = Kp * Td / T_amostra;

%% CONFIGURAÇÃO DA SIMULAÇÃO E MODELO
i = 3; % Seleção da variação paramétrica: 1, 2 ou 3

amostras = [300, 600, 900];
r_1t   = zeros(1, qde_amostras);
y_1t   = zeros(1, qde_amostras);
y_11t  = zeros(1, qde_amostras);
u_1t   = zeros(1, qde_amostras);
erro   = zeros(1, qde_amostras);

% Perfil de Referência Degrau (idêntico ao Fuzzy)
r_1t(1:amostras(1)) = 30;
r_1t((amostras(1)+1):amostras(2)) = 36;
r_1t((amostras(2)+1):amostras(3)) = 33;

tempo = (0:qde_amostras-1) * T_amostra;
y_1t_inicial = 22;

% Condição inicial e ponteiro de amostragem
if i ~= 3
    n11 = num_mat{i,1}; d11 = den_mat{i,1};
    cont = am_Td11(i) + 2;
else
    cont = 6;
end
% soma_erro = 0;
% Inicialização das condições de contorno
for k = 1:(cont-1)
    y_1t(k) = y_1t_inicial;
    erro(k) = r_1t(k) - y_1t(k);
    % soma_erro = abs(erro(k)) + soma_erro;
    u_1t(k) = 0;
end

%% LOOP DE CONTROLE PID
for k = cont:qde_amostras
    % Resposta dinâmica da planta
    if i == 3
        y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    else
        y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*u_1t(k-am_Td11(i)) + n11(2)*u_1t(k-am_Td11(i)-1);
    end

    % Saída real com offset inicial
    y_1t(k) = y_11t(k) + y_1t_inicial;

    % Cálculo do Erro
    erro(k) = r_1t(k) - y_1t(k);
   % soma_erro = abs(erro(k)) + soma_erro;
    % Calculo do sinal de controle
    u_1t(k) = u_1t(k-1) + g0*erro(k) + g1*erro(k-1) + g2*erro(k-2);

    % Saturação do Sinal de Controle [0, 100]% 
    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
end
%disp(soma_erro);

%% SALVAMENTO DOS DADOS EM TABELA CSV
T = table(tempo(:), r_1t(:), y_1t(:), u_1t(:), erro(:), ...
    'VariableNames', {'Tempo', 'Referencia_Temperatura', 'Saida_Temperatura', 'Controle_Temperatura', 'Erro_Temperatura'});

switch i
    case 1
        filename = 'Tables/incubadora_var_param1PID_Temp.csv';
    case 2
        filename = 'Tables/incubadora_var_param2PID_Temp.csv';
    otherwise
        filename = 'Tables/incubadora_var_param100PID_Temp.csv';
end

if ~exist('Tables', 'dir'), mkdir('Tables'); end
writetable(T, filename);
disp(['Dados PID salvos com sucesso em: ' filename]);

%% PLOTAGEM DOS RESULTADOS
figure(4); clf(figure(4));

subplot(2, 1, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_1t, 'b', 'LineWidth', 2);
title(['Saída de Temperatura - PID 2º Método ZN (Caso i = ' num2str(i) ')']);
xlabel('Tempo (min)'); ylabel('Temperatura (°C)');
legend('Referência', 'Saída PID'); grid on; hold off;

subplot(2, 1, 2);
plot(tempo/60, u_1t, 'g', 'LineWidth', 1.5);
title('Sinal de Controle (u_1)');
xlabel('Tempo (min)'); ylabel('Sinal de Controle (%)'); grid on;