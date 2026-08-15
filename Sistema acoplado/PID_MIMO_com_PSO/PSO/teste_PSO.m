%===========================================
% Script de Sintonia PSO para PID
% Este script executa a otimização por enxame de partículas.
%
% VARIÁVEIS PRINCIPAIS:
%   dim    - Número de dimensões (Kp, Ki, Kd)
%   n_pop  - Tamanho da população (número de partículas)
%   lim_v  - Matriz [min max] da velocidade das partículas
%   lim_p  - Matriz [min max] dos ganhos do controlador
%   max_it - Máximo de iterações do algoritmo
%   AC1 e AC2 - Pesos de aprendizado individual e social
%===========================================
clear all;
close all;

%% Controlador PID
dim = 3;          % [Scalar] Quantidade de parâmetros a otimizar (ex: Kp, Ki, Kd)
n_pop = 40;       % [Integer] Quantidade de agentes na busca
 lim_v = [-6 6;   % [Matrix] de velocidades [min, max] para cada parâmetro [Kp;Ki;Kd]
          -3 3;
          -1 1]; 
lim_p = [0.01 100; % [Matrix] Limites de posicao[min, max] para cada parâmetro [Kp;Ki;Kd]
         0.01 300;    %60                                               
         0.01 100];%30
max_it = 70;
     
%% Controlador FPID
% dim = 4;
% n_pop = 30;
% 
% lim_v = [-5 5;
%          -5 5  
%          -1 1
%          -1 1];
% 
% lim_p = [0.01 50; 
%          0.01 50;
%          0.01 15;
%          0.01 15];
% 
% max_it = 5000;
%%

AC1 = 2; AC2 = 2;
% Chamando o PSO
%[melhor pos todos_melhore] = PSO(dim, n_pop, lim_v, lim_p, max_it, AC1, AC2)
[melhor pos todos_melhore] = PSOGlobal(dim, n_pop, lim_v, lim_p, max_it, AC1, AC2)
%[melhor pos todos_melhore] = PSOLocal(dim, n_pop, lim_v, lim_p, max_it, AC1, AC2)