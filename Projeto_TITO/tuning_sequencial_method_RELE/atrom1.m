% ----- SCRIPT - ITEM B - CTRLLER PID MÉTODO SEQUENCIAL DESCENTRALIZADO ----- 
% Modelo de uma incubadora neonatal
% Temperatura inicial de 22 °C e 50% de umidade relativa
%--------------------------------------------------------------------------
% Parte 1 - Identificação da malha de temperatura com relé
clear; close all;

qtde_amostras = 600;
T_amost = 18;

% Parâmetros do relé
u_medio = 15;
d = 15;          
eps = 0.5;  % Pequena histerese para evitar chaveamento excessivo

% Condições iniciais do processo
y_1mft_inicial = 22; % Temperatura inicial
y_2mfu_inicial = 50; % Umidade inicial

% Inicializações
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);

% Referências
r_1t = 30 * ones(1, qtde_amostras);  % Setpoint de temperatura
% r_2u = y_2mfu_inicial * ones(1, qtde_amostras);  % Umidade em malha aberta
u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);  % Malha de umidade aberta - valor constante
% Inicialização das primeiras amostras (considerando os atrasos)
for k = 1:7
    tempo(k) = (k) * T_amost;
    u_1t(k) = u_medio+d;
    u_2u(k) = 0;
    y_1t(k) = y_1mft_inicial;
    y_2u(k) = y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
end

% EXECUTANDO O MÉTODO DO RELÉ - MALHA DE TEMPERATURA
for k = 8:qtde_amostras
    % Modelo do processo TITO
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.03556 * u_2u(k-3) - 0.1718 * u_2u(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);
    
    % Saídas totais
    y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
    
    % Erro da malha de temperatura
    erro1(k) = r_1t(k) - y_1t(k);
    
    % Malha de umidade em aberto (mantém valor constante)
    u_2u(k) = 0;
    
    % Lógica do relé para malha de temperatura
    % Assumindo que o seu modelo TITO foi identificado para a variação (desvio) do controle
    % A lei de controle atua para corrigir o erro em relação ao setpoint de 30ºC
    if erro1(k) > eps
        u_1t(k) = u_medio+d;      
    elseif erro1(k) < -eps
        u_1t(k) = u_medio-d;     
    else
        u_1t(k) = u_1t(k-1);
    end
    
    tempo(k) = (k-1) * T_amost;
end

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
plot(tempo, u_2u, 'k--', 'LineWidth', 1);
ylabel('Umidade (%)');
xlabel('Tempo (s)');
title('Resposta da Malha de Umidade (Aberta)');
legend('Umidade', 'Referência', 'Location', 'best');
grid on
hold off
% 
% % Análise da oscilação para método de Astrom-Hagglund
% fprintf('Análise da Oscilação:\n');
% fprintf('Amplitude do relé (d): %.2f\n', d);
% fprintf('Setpoint de temperatura: %.2f°C\n', r_1t(1));
% 
% %------------------------------------------------------------------------
% % Sintonia de Controladores PID pelo Método de Astrom
% %------------------------------------------------------------------------
a = 4.8678;
Tu = 576;
omega = (2*pi)/(Tu);
%Calculo de r_a, r_b, phi_a e phi_b
Gw_real = -(pi*sqrt(a^2 - eps^2)) / (4*d);
Gw_imag = -(pi*eps) / (4*d);
r_a = abs(Gw_real - j*Gw_imag);
phi_a = atan(eps / sqrt(a^2 - eps^2));
%a relacoa entre ra e rb => dependendo a razao entre os dois altera-se a
%dinamica apresentada na saida, en torno de 4 a saída tornava-se instavel
phi_b = pi * 40 / 180;
r_b =  2*r_a;

%Calculos dos parametros do controlador PID
Kp1 = r_b * cos(phi_b - phi_a) / r_a
aux1 = tan(phi_b - phi_a);
aux2 = sqrt(1 + aux1^2);
aux3 = aux1 + aux2;
Ti1 = aux3 / (2 * omega * 0.25);
Td2 = 0.25 * Ti1;

Ki1 = Kp1 / Ti1
Kd2 = Kp1 * Td2

g0_1 = Kp1 * (1 + (Td2 / T_amost) + (T_amost / Ti1));
g1_1 = -Kp1 * (1 + 2 * (Td2 / T_amost));
g2_1 = Kp1 * Td2 / T_amost;

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
    u_2u(k) = 0;
    u_1t(k) = u_1t(k-1) + g0_1 * erro1(k) + g1_1 * erro1(k-1) + g2_1 * erro1(k-2);

    tempo(k) = k * T_amost;
end


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

