% --- SCRIPT - OBTENÇÃO DE FUNÇÕES DE TRANSFERÊNCIA NO DOMÍNIO S E Z ---
clear; clc; close all;
k = 0.1;

% GERAR FUNÇÃO DE TRANSFERÊNCIA NO DOMÍNIO S
% Gs_11 é o seu sistema de interesse para a simulação
Gs_11 = tf([2.89], [550 1],'InputDelay',55);
Gs_12 = tf([-3.1*k], [260 1],'InputDelay',51);
Gs_21 = tf([-4.22], [546 1],'InputDelay',91);
Gs_22 = tf([22.22*k], [180 1],'InputDelay',16);

% APLICAÇÃO DO FEEDBACK
% O Gs_11_mf em malha fechada é o sistema que você quer simular
Gs_11_mf = feedback(Gs_11, 1);
Gs_22_mf = feedback(Gs_22, 1);

%% Implementação de condições iniciais em tempo contínuo
%Condicoes inciais Temperatura

% 1. Definir os valores
temp_inicial = 22; % Condição inicial (y(0) = 22)
valor_degrauT = 30; % Valor final desejado
amplitude_degrauT = valor_degrauT - temp_inicial; % Amplitude do degrau a ser simulado

% 2. Simular a resposta de degrau com a função 'step'
%    A função 'step' assume condições iniciais zero.
%    A entrada de degrau tem a amplitude calculada para a mudança de valor.
tt = 0:0.1:1000; % tempo de simulação
[yt_degrau, t_step] = step(amplitude_degrauT * Gs_11_mf, tt);

% 3. Aplicar o princípio da superposição
%    Adicionar a condição inicial à resposta do degrau.
yt_final = yt_degrau + temp_inicial;

% 4. Plotar o resultado
figure(1);
plot(t_step, yt_final, 'b', 'LineWidth', 1.5);
grid on;
title('Resposta da Saída com Condições Iniciais');
xlabel('Tempo (s)');
ylabel('Temperatura (°C)');
hold on;
plot(t_step, valor_degrauT * ones(size(t_step)), 'r--', 'LineWidth', 1);
legend('Resposta do Sistema', 'Referência', 'Location', 'best');
hold off;

%Condicoes inciais umidade

% 1. Definir os valores
umid_inicial = 50; % Condição inicial (y(0) = 22)
valor_degrauU = 50; % Valor final desejado
amplitude_degrauU = valor_degrauU - umid_inicial; % Amplitude do degrau a ser simulado

% 2. Simular a resposta de degrau com a função 'step'
%    A função 'step' assume condições iniciais zero.
%    A entrada de degrau tem a amplitude calculada para a mudança de valor.
tu = 0:0.1:1000; % tempo de simulação
[yu_degrau, t_step] = step(amplitude_degrauU * Gs_22_mf, tu);

% 3. Aplicar o princípio da superposição
%    Adicionar a condição inicial à resposta do degrau.
yu_final = yu_degrau + umid_inicial;

% 4. Plotar o resultado
figure(2);
plot(t_step, yu_final, 'b', 'LineWidth', 1.5);
grid on;
title('Resposta da Saída com Condições Iniciais');
xlabel('Tempo (s)');
ylabel('Umidade (%)');
hold on;
plot(t_step, valor_degrauU * ones(size(t_step)), 'r--', 'LineWidth', 1);
legend('Resposta do Sistema', 'Referência', 'Location', 'best');
hold off;
%% Simulação no domínio Z (discretizado)
% O seu código de discretização original
T_amost = 18;
Gz_11 = c2d(Gs_11, T_amost, 'zoh')
Gz_12 = c2d(Gs_12, T_amost, 'zoh')
Gz_21 = c2d(Gs_21, T_amost, 'zoh')
Gz_22 = c2d(Gs_22, T_amost, 'zoh')

% Exibir matriz Gz
Gz = [Gz_11 Gz_12;
      Gz_21 Gz_22]

% % OBTENÇÃO DE DESACOPLADOR E DISCRETIZAÇÃO
% Ds_12 = tf([0.31*550 3.1], [2.89*260 2.89],'InputDelay',0);
% Ds_21 = tf([4.22*180 4.22], [2.222*546 2.222],'InputDelay',75);
% 
% % PLANO S -> PLANO Z
% Dz_12 = c2d(Ds_12, T_amost, 'zoh');
% Dz_21 = c2d(Ds_21, T_amost, 'zoh');
% 
% % EXIBIR MATRIZ
% Dz = [1 Dz_12; Dz_21 1];