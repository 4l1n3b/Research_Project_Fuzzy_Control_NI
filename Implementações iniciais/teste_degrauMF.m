% --- MALHA FECHADA SISTEMA TITO COM PATRÕES DIFERENTES EM R1 E R2 ---

clear all; close all; clc;

%% Planta contínua com atrasos
G11 = tf([2.89], [550 1], 'InputDelay', 55);
G12 = tf([-3.1], [260 1], 'InputDelay', 51);
G21 = tf([-4.22], [546 1], 'InputDelay', 91);
G22 = tf([22.22], [180 1], 'InputDelay', 16);

%% Controladores (P para simplificar)
C1 = tf(1);  % ganho proporcional da malha 1
C2 = tf(1);  % ganho proporcional da malha 2

%% Sistema multivariável
G = [G11 G12; G21 G22];
C = [C1 0; 0 C2];  % controle descentralizado

% Malha fechada: T(s) = G(s)*C(s) / (I + G(s)*C(s))
I = eye(2);
T = feedback(G*C, I);

%% Tempo de simulação
t = linspace(0, 5000, 2000);  % tempo em segundos

%% Definição da referência com dois patamares
r1 = ones(size(t));  % referência fixa em 1 para y1

% referência alternada para y2:
r2 = zeros(size(t));
r2(t > 1000 & t <= 2500) = 1;    % degrau para 1
r2(t > 2500) = -1;               % patamar negativo

r = [r1; r2];  % matriz 2xN com as referências

%% Simulação
[y, ~, ~] = lsim(T, r', t);

%% Plot
figure;

subplot(2,1,1)
plot(t/60, r1, 'k--', t/60, y(:,1), 'b', 'LineWidth', 1.5); grid on;
title('Saída y_1 (Referência constante)');
xlabel('Tempo [min]'); ylabel('y_1');
legend('Referência r_1', 'Saída y_1');

subplot(2,1,2)
plot(t/60, r2, 'k--', t/60, y(:,2), 'r', 'LineWidth', 1.5); grid on;
title('Saída y_2 (Patamares alternados)');
xlabel('Tempo [min]'); ylabel('y_2');
legend('Referência r_2', 'Saída y_2');
