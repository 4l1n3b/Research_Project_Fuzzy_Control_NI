% ----- SCRIPT -  ITEM B - CTRLLER PID MÉTODO SEQUENCIAL DESCENTRALIZADO -----

%--------------------------------------------------------------------------

clear all;
close all;

qtde_amostras = 600;
T_amost = 18;


%% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);
dt = 15;
du = 20;
% Condições iniciais
y_1_inicial = 22;
y_2_inicial = 50;
for k = 1:7
    tempo(k) = k*T_amost;
     % As entradas são os setpoints de referência.
    u_1t(k) = 22 - dt;
    u_2u(k) = 50 - du;
    
    % As saídas do sistema inicializadas com os mesmos
    % valores das entradas para simular as condições iniciais.
    y_1t(k) = y_1_inicial;
    y_2u(k) = y_2_inicial;
    
    % Inicialização do vetor de tempo e erro. Com a saída = entrada,
    % o erro inicial é zero, como esperado para um estado de equilíbrio.
    tempo(k) = k*T_amost;
    erro1(k) = 0;%u_1t(k) - y_1mft(k);
    erro2(k) = 0;%u_2u(k) - y_2mfu(k);
end


%------------------------------------------------------------------------
% Controladores PID pelo Método de Astrom
%------------------------------------------------------------------------
%% FIXANDO PARAMETROS DOS CONTROLADORES
%Controlador da malha 1 - TEMPERATURA
Kp1 = 1.3961;
Kd1 = 76.2931;
Ki1 = 0.0064;

g0_1 = Kp1  + Kd1 / T_amost + (T_amost *Ki1);
g1_1 = -Kp1 - 2 * (Kd1 / T_amost);
g2_1 = Kd1/ T_amost;

% Controlador da malha 2 - UMIDADE
Kp2 = 2.1525;
Kd2 = 36.4522;
Ki2 = 0.0318;

g0_2 = Kp2  + Kd2 / T_amost + (T_amost *Ki2);
g1_2 = -Kp2 - 2 * (Kd2 / T_amost);
g2_2 = Kd2 / T_amost;

%% INICIALIZANDO PATAM,ARES
%definindo patamares da entrada 1
r_1t(1:qtde_amostras / 3) = 30;
r_1t(qtde_amostras /3+1:2*qtde_amostras/3) = 36;
r_1t(2*qtde_amostras/3+1:qtde_amostras) = 36;
%definindo patamares da entrada 2
r_2u(1:qtde_amostras / 3) = 50;
r_2u(qtde_amostras /3+1:2*qtde_amostras/3) = 50;
r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55;

%% LOOP DE CONTROLE
for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);

    %Saídas do processo
    y_1t(k) = y_11t(k) + y_12u(k) +y_1_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2_inicial;
    %calculo do erro em cada malha
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    %calculo do sinal de controle para correção do erro
    u_1t(k) = u_1t(k-1) + g0_1 * erro1(k) + g1_1 * erro1(k-1) + g2_1 * erro1(k-2);
    u_2u(k) = u_2u(k-1) + g0_2 * erro2(k) + g1_2 * erro2(k-1) + g2_2 * erro2(k-2);

    tempo(k) = k * T_amost;
end
minLength = min(length(tempo), length(r_2u));
%% PLOTAGEM DE GRÁFICOS
% Subplot para r_1, y_1 e u_1
figure(2);
subplot(2,2,1)
hold on
plot(tempo/60, r_1t, 'b', 'LineWidth', 1.5);
plot(tempo/60, y_1t, 'r', 'LineWidth', 1);
ylabel('Temperatura(°C)');
xlabel('Tempo(min)');
title('Referência de Temperatura e Saida de Temperatura');
legend('Referência de Temperatura - r_{1t}', 'Saida de Temperatura - y_{1t}');
hold off
grid on


subplot(2,2,3)
plot(tempo/60, u_1t, 'g', 'LineWidth', 1);
xlabel('Tempo (min)');
ylabel('Temperatura(°C)');
title('Sinal de Controle - u_{1t}')
grid on

subplot(2,2,2)
hold on
plot(tempo/60, r_2u, 'b', 'LineWidth', 1.5);
plot(tempo/60, y_2u, 'r', 'LineWidth', 1);
ylabel('Umidade Relativa (%)');
xlabel('Tempo(min)');
title('Referência de Umidade e Saida de Umidade');
legend('Referência de Umidade - r_{2u}', 'Saida de Umidade- y_{2u}');
hold off
grid on

subplot(2,2,4)
plot(tempo/60, u_2u, 'g', 'LineWidth', 1);
xlabel('Tempo(min)')
ylabel('Umidade Relativa (%)')
title('Sinal de Controle - u_{2u}')
grid on

% ==== SALVAR DADOS EM PLANILHA ====
T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
    'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});

filename = 'dados_PID_astrom_incubadora.csv';
writetable(T, filename);
disp(['Dados salvos em: ' filename]);

% ==== LER DADOS DA PLANILHA ====
T_lida = readtable(filename);

disp('Primeiras linhas dos dados lidos:');
disp(head(T_lida));

% Se quiser usar as variáveis separadas:
Tempo = T_lida.Tempo;
r_1t = T_lida.Referencia_Temperatura;
r_2u = T_lida.Referencia_Umidade;
y_1t = T_lida.Saida_Temperatura;
y_2u = T_lida.Saida_Umidade;
u_1t = T_lida.Sinal_Controle_Temperatura;
u_2u = T_lida.Sinal_Controle_Umidade;
erro1 = T_lida.Erro_Temperatura;
erro2 = T_lida.Erro_Umidade;
