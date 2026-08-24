% ----- SCRIPT -  ITEM B - CTRLLER PID MÉTODO SEQUENCIAL DESCENTRALIZADO -----

%--------------------------------------------------------------------------
%temperatura2

%%
clear all; close all; clc;

qtde_amostras = 600;  % Aumentei para garantir estabilização
T_amost = 18;

% Parâmetros do relé - ajuste conforme necessário
d = 15;          % Reduzi a amplitude para evitar saturação
eps = .5;       % Pequena histerese para evitar chaveamento excessivo
% Condições iniciais do processo
y_1mft_inicial = 22; % Temperatura inicial (Offset)
y_2mfu_inicial = 50; % Umidade inicial (Offset)

% Variáveis do controlador da malha 1 (temperatura)
Kp2 = 0.7303;
Kd2 = 16.8768;
Ki2 = 0.0079;
g0_2 = Kp2 + Kd2/T_amost + (T_amost * Ki2);
g1_2 = -Kp2 - 2 * (Kd2 / T_amost);
g2_2 = Kd2 / T_amost;

% Inicializações
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

% Referências - Ponto de Projeto
r_1t = 30 * ones(1, qtde_amostras);  % Setpoint de Temperatura (Controlada por PID)
r_2u = 50 * ones(1, qtde_amostras);  % Setpoint de Umidade (Identificada por Relé)


% Parâmetro de polarização (Bias) para o relé de Umidade
% Como r_2u é 50, o bias deve ser o valor de controle u_2u que mantém 50%.
uu_medio = 10; 
ut_medio = 15;
% Inicialização
for k = 1:7
    tempo(k) = k*T_amost;
    % Inicializa sinais de controle nos valores de regime (Bias)
    u_2u(k) = ut_medio + d;
    u_2u(k) = uu_medio; 
    
    y_1t(k) = y_1mft_inicial;
    y_2u(k) = y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
end

% LOOP PRINCIPAL CORRIGIDO
for k = 8:qtde_amostras
    % Modelo do processo
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
    
    % Saídas do processo
    y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;  % 22 condicao inicial
    y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;  % 50 condicao incial
    
    % Erro da malha de temperatura (controlada por PID)
    erro1(k) = r_1t(k) - y_1t(k);
    
    % Erro da malha de umidade (com relé)
    erro2(k) = r_2u(k) - y_2u(k);
    u_2u(k) = u_2u(k-1) + g0_2 * erro2(k) + g1_2 * erro2(k-1) + g2_2 * erro2(k-2);
    
    % Saturação/Anti-windup (CRUCIAL) - Assume limites de 0 a 100
    if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
    % Lógica SIMPLIFICADA do relé para umidade
    if erro1(k) > eps
        u_1t(k) = ut_medio + d;  % Acima do setpoint
    elseif erro1(k) < -eps
        u_1t(k) = ut_medio - d;  % Abaixo do setpoint  
    else
        u_1t(k) = u_1t(k-1);  % Mantém último valor (histerese)
    end
    % Saturação/Anti-windup (CRUCIAL) - Assume limites de 0 a 100
    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
    tempo(k) = (k) * T_amost;
end

% % Cálculo do período de oscilação
% kont = 0;
% 
% for k = 3:qtde_amostras
%     if u_1t(k) ~= u_1t(k-1)
%         kont = kont + 1;
%         ch(kont) = k;
%     end
% end
% 
% Tu1 = (ch(3) - ch(2))*T_amost;
% Tu2 = (ch(4) - ch(3))*T_amost;
% Tu = Tu1 + Tu2;
% omega = (2*pi)/(Tu);
% 
% %Calculo da amplitude da ocilacao
% amax = -Inf;  % Começa bem baixo para garantir que será substituído
% amin = Inf;   % Começa bem alto para garantir que será substituído
% 
% % 40 amostras é mais ou menos onde a oscilacao esta sustentada
% for k = 40:qtde_amostras
%     if y_1(k) > amax
%         amax = y_1(k);
%     end
%     if y_1(k) < amin
%         amin = y_1(k);
%     end
% end
% 
% a = (amax - amin) / 2;

% Gráfico da oscilação com relé
figure(1)
subplot(3,1,1)
hold on
plot(tempo, r_1t, 'r--', 'LineWidth', 1.5);
plot(tempo, y_1t, 'b-', 'LineWidth', 1);
plot(tempo, u_1t, 'g', 'LineWidth', 1.5);
ylabel('Temperatura (°C)');
xlabel('Tempo (s)');
title('Resposta da Malha de Temperatura com Relé');
legend('Setpoint', 'Temperatura', 'Relé', 'Location', 'best');
grid on
hold off

subplot(3,1,2)
hold on

ylabel('Sinal de Controle u_{1t}');
xlabel('Tempo (s)');
title('Sinal do Relé na Malha de Temperatura');
grid on
hold off

subplot(3,1,3)
hold on
plot(tempo, y_2u, 'm-', 'LineWidth', 1.5);
plot(tempo, r_2u, 'k--', 'LineWidth', 1);
ylabel('Umidade (%)');
xlabel('Tempo (s)');
title('Resposta da Malha de Umidade (Aberta)');
legend('Umidade', 'Referência', 'Location', 'best');
grid on
hold off

% 
% % %%
%------------------------------------------------------------------------
% Sintonia de Controladores PID pelo Método de Astrom
%------------------------------------------------------------------------
a = 4.8924;
Tu = 468;
omega = (2*pi)/(Tu);
%Calculo de r_a, r_b, phi_a e phi_b
Gw_real = -(pi*sqrt(a^2 - eps^2)) / (4*d);
Gw_imag = -(pi*eps) / (4*d);
r_a = abs(Gw_real - j*Gw_imag);
phi_a = atan(eps / sqrt(a^2 - eps^2));

%a relacoa entre ra e rb => dependendo a razao entre os dois altera-se a
%dinamica apresentada na saida, en torno de 3.5 a 4 a saída tornava-se instavel
phi_b = pi * 30/ 180;
r_b = 1*r_a;

% Parametros do PID de umidade 
Kp2 = 0.7303;
Kd2 = 16.8768;
Ki2 = 0.0079;
g0_2 = Kp2 + Kd2/T_amost + (T_amost * Ki2);
g1_2 = -Kp2 - 2 * (Kd2 / T_amost);
g2_2 = Kd2 / T_amost;

%Calculos dos parametros do controlador PID
Kp1 = r_b * cos(phi_b - phi_a) / r_a
aux1 = tan(phi_b - phi_a);
aux2 = sqrt(1 + aux1^2);
aux3 = aux1 + aux2;
Ti1 = aux3 / (2 * omega * 0.25);
Td1 = 0.25 * Ti1;

Ki1 = Kp1 / Ti1
Kd1 = Kp1 * Td1

g0_1 = Kp1 * (1 + (Td1 / T_amost) + (T_amost / Ti1));
g1_1 = -Kp1 * (1 + 2 * (Td1 / T_amost));
g2_1 = Kp1 * Td1 / T_amost;
qtde_amostras = 900;

%definindo patamares da entrada 1
r_1t(1:qtde_amostras / 3) = 30;
r_1t(qtde_amostras /3+1:2*qtde_amostras/3) = 36;
r_1t(2*qtde_amostras/3+1:qtde_amostras) = 36;
%definindo patamares da entrada 2
r_2u(1:qtde_amostras / 3) = 50;
r_2u(qtde_amostras /3+1:2*qtde_amostras/3) = 50;
r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55;

% Loop de controle
for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);

    y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    % Controlador temperatura
    u_1t(k) = u_1t(k-1) + g0_1 * erro1(k) + g1_1 * erro1(k-1) + g2_1 * erro1(k-2);

    % Controlador umidade  
    u_2u(k) = u_2u(k-1) + g0_2 * erro2(k) + g1_2 * erro2(k-1) + g2_2 * erro2(k-2);
        %saturacao do controlador
    if u_1t(k) > 100
        u_1t(k) = 100;
    end
    if u_2u(k) > 100
        u_2u(k) = 100;
    end
    if u_1t(k) < 0
        u_1t(k) = 0;
    end
    if u_2u(k) < 0
        u_2u(k) = 0;
    end
    tempo(k) = k * T_amost;
end
% minLength = min(length(tempo), length(r_2u));

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
