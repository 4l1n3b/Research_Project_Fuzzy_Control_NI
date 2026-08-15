% --- SCRIPT - DEGRADUO NO SISTEMA TITO CONTÍNUO (S) ---
clear all; close all; clc;

%% DEFINIÇÃO DAS FUNÇÕES DE TRANSFERÊNCIA (S)
Gs_11 = tf([2.89], [550 1],'InputDelay',55);
Gs_12 = tf([-3.1], [260 1],'InputDelay',51);
Gs_21 = tf([-4.22], [546 1],'InputDelay',91);
Gs_22 = tf([22.22], [180 1],'InputDelay',16);

%% TEMPO DE SIMULAÇÃO
t_final = 5000;               % em segundos
t = linspace(0, t_final, 2000);

%% DEFINIÇÃO DAS ENTRADAS
u1 = ones(size(t))*35;           % degrau unitário na entrada 1
u2 = ones(size(t))*70;          % entrada 2 em zero

%% SIMULAÇÃO INDIVIDUAL DOS BLOCOS
% y_11: resposta de y1 ao degrau em u1 via Gs_11
y_11 = lsim(Gs_11, u1, t);

% y_12: resposta de y1 ao degrau em u2 via Gs_12
y_12 = lsim(Gs_12, u2, t);

% y_21: resposta de y2 ao degrau em u1 via Gs_21
y_21 = lsim(Gs_21, u1, t);

% y_22: resposta de y2 ao degrau em u2 via Gs_22
y_22 = lsim(Gs_22, u2, t);

%% COMPOSIÇÃO DAS SAÍDAS TOTAIS
y1 = y_11 + y_12;
y2 = y_21 + y_22;

%% PLOTAGEM
figure;

subplot(2,1,1)
plot(t/60, y1, 'b', 'LineWidth', 1.5); grid on;
title('Resposta de y_1 ao degrau em u_1 (domínio S)');
xlabel('Tempo [min]'); ylabel('y_1');

subplot(2,1,2)
plot(t/60, y2, 'r', 'LineWidth', 1.5); grid on;
title('Resposta de y_2 ao degrau em u_1 (domínio S)');
xlabel('Tempo [min]'); ylabel('y_2');
