%==========================================================================
% CONTROLADOR FUZZY P/ MODELO DE INCUBADORA
%==========================================================================
clear; clear all; clc; close all;

qtde_amostras = 900;
T_amost = 18;

%% ========================================================================
% INICIALIZAÇÕES
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);

y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
de1 = zeros(1, qtde_amostras);
de2 = zeros(1, qtde_amostras);
% tempo = zeros(1, qtde_amostras);

% Definindo as condições iniciais de 22°C e 50%
y_1t_inicial = 22; % Condição inicial da saída de temperatura
y_2u_inicial = 50; % Condição inicial da saída de umidade

% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t(1:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(1:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;

u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;


% TEMPERATURE
Escala_eT = 1/22;%1/18
Escala_deT = 1/3; 
Escala_duT = 2;

% HUMIDITY
Escala_eU = 1/30;%1/15
Escala_deU= 1/7; 
Escala_duU = 2;

%% Definir funcoes de pertinencia
%Temperatura
    % Universo de discurso (local)
    u_disc = linspace(-1, 1, 10000);

    % Defining membership functions (MP)
    error_GN_T   = trapezoidal(u_disc, -2, -1, -.85, -0.7);
    error_PN_T   = triangular(u_disc, -.9, -.7, 0);
    error_zero_T  = triangular(u_disc, -.7, 0, .7);
    error_PP_T   = triangular(u_disc, 0, .6, .8);
    error_GP_T    = trapezoidal(u_disc, 0.5, .7, 1, 2);
    
    var_error_GN_T   = trapezoidal(u_disc, -2, -1, -.9, -0.5);
    var_error_PN_T   = triangular(u_disc, -1, -.5, 0);
    var_error_zero_T  = triangular(u_disc, -.5, 0, .5);
    var_error_PP_T   = triangular(u_disc, 0, .5, 1);
    var_error_GP_T    = trapezoidal(u_disc, 0.5, .9, 1, 2);

    % Singletons de saida
    vGPT   = 1; vPPT = .2; vZT = 0; vPNT = -.5; vGNT = -1;
% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
% Gráficos
% Definição das cores suaves (RGB)
cores = {
    [0.85, 0.33, 0.31], ... % GN
    [0.93, 0.69, 0.39], ... % PN
    [0.93, 0.84, 0.39], ... % zero/Z
    [0.64, 0.45, 0.68], ... % PP
    [0.47, 0.67, 0.35]      % GP
};
labels = {'GN', 'PN', 'Z', 'PP', 'GP'};

figure(1);

% --- Subplot 1: Erro ---
subplot(1,3,1)
hold on;
funcoes_erro = {error_GN_T, error_PN_T, error_zero_T, error_PP_T, error_GP_T};
for i = 1:5
    plot(u_disc, funcoes_erro{i}, 'Color', cores{i}, 'LineWidth', 3);
    % Encontra o valor máximo para posicionar a label no topo da função
    [max_val, idx] = max(funcoes_erro{i});
    text(u_disc(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Entrada: Erro');
xlabel('Erro');
ylabel('Grau de Pertinência (\mu)');
axis([-1 1 0 1.2]); grid on; hold off;

% --- Subplot 2: Variação do Erro ---
subplot(1,3,2)
hold on;
funcoes_var = {var_error_GN_T, var_error_PN_T, var_error_zero_T, var_error_PP_T, var_error_GP_T};
for i = 1:5
    plot(u_disc, funcoes_var{i}, 'Color', cores{i}, 'LineWidth', 3);
    [max_val, idx] = max(funcoes_var{i});
    text(u_disc(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Entrada: Variação do Erro');
xlabel('Variação do Erro');
ylabel('Grau de Pertinência (\mu)');
axis([-1 1 0 1.2]); grid on; hold off;

% --- Subplot 3: Saída (Singletons) ---
subplot(1,3,3)
x_coord = [vGNT, vPNT, vZT, vPPT, vGPT];
y_coord = ones(1, 5); 
hold on;
for i = 1:length(x_coord)
    stem(x_coord(i), y_coord(i), 'LineWidth', 3, 'Color', cores{i}, ...
        'MarkerFaceColor', cores{i}, 'Marker', 'o', 'MarkerSize', 6);
    
    text(x_coord(i), 1.1, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end
set(gca, 'XTick', x_coord, 'XTickLabel', x_coord); 
title('Saída: Variação do Sinal de Controle');
xlabel('Valor do Singleton');
ylabel('Grau de Pertinência (\mu)');
axis([-1.5 2 0 1.25]); grid on; hold off;
%Umidade
    % Universo de discurso (local para a função)
    % u_disc = linspace(-1, 1, 10000);

    % Defining membership functions (MP)
    error_GN_U   = trapezoidal(u_disc, -2, -1, -.85, -0.7);
    error_PN_U   = triangular(u_disc, -.9, -.7, 0);
    error_zero_U  = triangular(u_disc, -.6, 0, .5);
    error_PP_U   = triangular(u_disc, 0, .5, .9);
    error_GP_U    = trapezoidal(u_disc, 0.5, .85, 1, 2);
    
    var_error_GN_U   = trapezoidal(u_disc, -2, -1, -.7, -0.5);
    var_error_PN_U   = triangular(u_disc, -1, -.5, 0);
    var_error_zero_U  = triangular(u_disc, -.5, 0, .4);
    var_error_PP_U   = triangular(u_disc, 0, .5, 1);
    var_error_GP_U    = trapezoidal(u_disc, 0.5, .7, 1, 2);

    % Singletons de saida
    vGPU = .9; vPPU = .2; vZU = 0; vPNU = -.5; vGNU = -1;
% Definição das cores e labels (Reutilizando para padronização)
cores = {
    [0.85, 0.33, 0.31], ... % GN
    [0.93, 0.69, 0.39], ... % PN
    [0.93, 0.84, 0.39], ... % Z
    [0.64, 0.45, 0.68], ... % PP
    [0.47, 0.67, 0.35]      % GP
};
labels = {'GN', 'PN', 'Z', 'PP', 'GP'};

figure(2);

% --- Subplot 1: Erro (_U) ---
subplot(1,3,1)
hold on;
funcoes_erro_U = {error_GN_U, error_PN_U, error_zero_U, error_PP_U, error_GP_U};
for i = 1:5
    plot(u_disc, funcoes_erro_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    % Posicionamento automático da label no topo de cada função
    [max_val, idx] = max(funcoes_erro_U{i});
    text(u_disc(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Entrada: Erro');
xlabel('Erro');
ylabel('Grau de Pertinência (\mu)');
axis([-1 1 0 1.2]); grid on; hold off;

% --- Subplot 2: Variação do Erro (_U) ---
subplot(1,3,2)
hold on;
funcoes_var_U = {var_error_GN_U, var_error_PN_U, var_error_zero_U, var_error_PP_U, var_error_GP_U};
for i = 1:5
    plot(u_disc, funcoes_var_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    [max_val, idx] = max(funcoes_var_U{i});
    text(u_disc(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Entrada: Variação do Erro');
xlabel('Variação do Erro');
ylabel('Grau de Pertinência (\mu)');
axis([-1 1 0 1.2]); grid on; hold off;

% --- Subplot 3: Saída (Singletons _U) ---
subplot(1,3,3)
x_coord_U = [vGNU, vPNU, vZU, vPPU, vGPU];
y_coord_U = ones(1, 5); 
hold on;
for i = 1:length(x_coord_U)
    stem(x_coord_U(i), y_coord_U(i), 'LineWidth', 3, 'Color', cores{i}, ...
        'MarkerFaceColor', cores{i}, 'Marker', 'o', 'MarkerSize', 6);
    
    text(x_coord_U(i), 1.1, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end
set(gca, 'XTick', x_coord_U, 'XTickLabel', x_coord_U); 
title('Saída: Variação do Sinal de Controle');
xlabel('Valor do Singleton');
ylabel('Grau de Pertinência (\mu)');
axis([-1.5 2 0 1.25]); grid on; hold off;
%% ========================================================================

for k = 1:7 
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro1_norm(k) = erro1(k)*Escala_eT;
    erro2(k) = r_2u(k) - y_2u(k);
    erro2_norm(k) = erro2(k)*Escala_eU;
    tempo(k) = (k) * T_amost;
end


% Load do arquivo .fis
% try
%     fuzzy1 = readfis('fuzzy_IN1_temperatura.fis');
% catch ME
%     error('Arquivo FIS não encontrado.');
% end
% try
%     fuzzy2 = readfis('fuzzy_IN2_umidade.fis');
% catch ME
%     error('Arquivo FIS não encontrado.');
% end

% SCALE FACTORS OF THE VARIABLES


%% LOOP DE CONTROLE

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.03556 * u_2u(k-3) - 0.1718 * u_2u(k-4);
    
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);
    
    % Saída do Sistema
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    
    % Cálculo do erro 
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    e1_fuzzy = erro1(k)*Escala_eT;
    e2_fuzzy = erro2(k)*Escala_eU;

    % Variação do Erro 
    de1(k) = erro1(k) - erro1(k-1); 
    de1_fuzzy = de1(k)*Escala_deT;
    de2(k) = erro2(k) - erro2(k-1); 
    de2_fuzzy = de2(k)*Escala_deU;
    %sinal de controle
    % Fuzzificação
    s1 = singleton(u_disc, error_GN_T, e1_fuzzy);
    s2 = singleton(u_disc, error_PN_T, e1_fuzzy);
    s3 = singleton(u_disc, error_zero_T, e1_fuzzy);
    s4 = singleton(u_disc, error_PP_T, e1_fuzzy);
    s5 = singleton(u_disc, error_GP_T, e1_fuzzy);
    
    s6 = singleton(u_disc, var_error_GN_T, de1_fuzzy);
    s7 = singleton(u_disc, var_error_PN_T, de1_fuzzy);
    s8 = singleton(u_disc, var_error_zero_T, de1_fuzzy);
    s9 = singleton(u_disc, var_error_PP_T, de1_fuzzy); 
    s10 = singleton(u_disc, var_error_GP_T, de1_fuzzy); 
    
    % Regras
    r1 = min(s1, s6); r2 = min(s1, s7); r3 = min(s1, s8); r4 = min(s1, s9); r5 = min(s1, s10);
    r6 = min(s2, s6); r7 = min(s2, s7); r8 = min(s2, s8); r9 = min(s2, s9); r10 = min(s2, s10);
    r11 = min(s3, s6); r12 = min(s3, s7); r13 = min(s3, s8); r14 = min(s3, s9); r15 = min(s3, s10);
    r16 = min(s4, s6); r17 = min(s4, s7); r18 = min(s4, s8); r19 = min(s4, s9); r20 = min(s4, s10);
    r21 = min(s5, s6); r22 = min(s5, s7); r23 = min(s5, s8); r24 = min(s5, s9); r25 = min(s5, s10);
    
    % Implicação
    out1 = r1 * vGNT; out2 = r2 * vPNT; out3 = r3 * vPNT; out4 = r4 * vPNT; out5 = r5 * vPPT;
    out6 = r6 * vGNT; out7 = r7 * vPNT; out8 = r8 * vPNT; out9 = r9 * vZT; out10 = r10 * vGPT;
    out11 = r11 * vPNT; out12 = r12 * vPNT; out13 = r13 * vZT; out14 = r14 * vPPT; out15 = r15 * vGNT;
    out16 = r16 * vPNT; out17 = r17 * vZT; out18 = r18 * vGPT; out19 = r19 * vGPT; out20 = r20 * vGPT;
    out21 = r21 * vPPT; out22 = r22 * vGPT; out23 = r23 * vGPT; out24 = r24 * vGPT; out25 = r25 * vGPT;

    % Agregação e Média Ponderada
    sum_weight = (r1+r2+r3+r4+r5+r6+r7+r8+r9+r10+r11+r12+r13+r14+r15+r16+r17+r18+r19+r20+r21+r22+r23+r24+r25);
    if sum_weight > 0
        sum_out = (out1+out2+out3+out4+out5+out6+out7+out8+out9+out10+out11+out12+out13+out14+out15+out16+out17+out18+out19+out20+out21+out22+out23+out24+out25);
        du_out = sum_out/ sum_weight;
    else
        du_out = 0;
    end

    % ================================================
    
    du1(k) = Escala_duT*du_out;
  
    u_1t(k) = u_1t(k-1) + du1(k);
   

    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
    % Fuzzificação
    s1 = singleton(u_disc, error_GN_U, e2_fuzzy);
    s2 = singleton(u_disc, error_PN_U, e2_fuzzy);
    s3 = singleton(u_disc, error_zero_U, e2_fuzzy);
    s4 = singleton(u_disc, error_PP_U, e2_fuzzy);
    s5 = singleton(u_disc, error_GP_U, e2_fuzzy);
    
    s6 = singleton(u_disc, var_error_GN_U, de2_fuzzy);
    s7 = singleton(u_disc, var_error_PN_U, de2_fuzzy);
    s8 = singleton(u_disc, var_error_zero_U, de2_fuzzy);
    s9 = singleton(u_disc, var_error_PP_U, de2_fuzzy); 
    s10 = singleton(u_disc, var_error_GP_U, de2_fuzzy); 

    % Regras e Implicação (Mamdani/Singleton)
    r1U = min(s1, s6);  out1_U = r1U * vGNU;
    r2U = min(s1, s7);  out2_U = r2U * vPNU;
    r3U = min(s1, s8);  out3_U = r3U * vPNU;
    r4U = min(s1, s9);  out4_U = r4U * vPNU;
    r5U = min(s1, s10); out5_U = r5U * vPPU;
    
    r6U = min(s2, s6);  out6_U = r6U * vGNU;
    r7U = min(s2, s7);  out7_U = r7U * vPNU;
    r8U = min(s2, s8);  out8_U = r8U * vPNU;
    r9U = min(s2, s9);  out9_U = r9U * vZU;
    r10U = min(s2, s10); out10_U = r10U * vGPU;
    
    r11U = min(s3, s6);  out11_U = r11U * vPNU;
    r12U = min(s3, s7);  out12_U = r12U * vPNU;
    r13U = min(s3, s8);  out13_U = r13U * vZU;
    r14U = min(s3, s9);  out14_U = r14U * vPPU;
    r15U = min(s3, s10); out15_U = r15U * vGNU;
    
    r16U = min(s4, s6);  out16_U = r16U * vPNU;
    r17U = min(s4, s7);  out17_U = r17U * vZU;
    r18U = min(s4, s8);  out18_U = r18U * vGPU;
    r19U = min(s4, s9);  out19_U = r19U * vGPU;
    r20U = min(s4, s10); out20_U = r20U * vGPU;
    
    r21U = min(s5, s6);  out21_U = r21U * vZU;
    r22U = min(s5, s7);  out22_U = r22U * vPPU;
    r23U = min(s5, s8);  out23_U = r23U * vGPU;
    r24U = min(s5, s9);  out24_U = r24U * vGPU;
    r25U = min(s5, s10); out25_U = r25U * vGPU;

    % Agregação e Defuzzificação (Média Ponderada)
    sum_weightU = (r1U+r2U+r3U+r4U+r5U+r6U+r7U+r8U+r9U+r10U+r11U+r12U+r13U+r14U+r15U+r16U+r17U+r18U+r19U+r20U+r21U+r22U+r23U+r24U+r25U);
    
    if sum_weightU > 0
        sum_outU = (out1_U+out2_U+out3_U+out4_U+out5_U+out6_U+out7_U+out8_U+out9_U+out10_U+out11_U+out12_U+out13_U+out14_U+out15_U+out16_U+out17_U+out18_U+out19_U+out20_U+out21_U+out22_U+out23_U+out24_U+out25_U);
        du_outU = sum_outU/ sum_weightU;
    else
        du_outU = 0;
    end
    du2(k) = Escala_duU*du_outU;
    u_2u(k) = u_2u(k-1) + du2(k);
   if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
end
  
%% ========================================================================
% GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) - TEMPERATURA E UMIDADE
%% ========================================================================
% 1. Definir a resolução (aumentada para 40 para curvas mais suaves)
res = 40; 
e_range = linspace(-1, 1, res);
de_range = linspace(-1, 1, res);
[E, DE] = meshgrid(e_range, de_range);

Z_temp = zeros(res, res);
Z_umid = zeros(res, res);

% 2. Loop para calcular a saída de ambas as variáveis
for i = 1:res
    for j = 1:res
        curr_e = E(i,j);
        curr_de = DE(i,j);

        % --- CÁLCULO PARA TEMPERATURA ---
        st = [singleton(u_disc, error_GN_T, curr_e), ...
              singleton(u_disc, error_PN_T, curr_e), ...
              singleton(u_disc, error_zero_T, curr_e), ...
              singleton(u_disc, error_PP_T, curr_e), ...
              singleton(u_disc, error_GP_T, curr_e)];

        std = [singleton(u_disc, var_error_GN_T, curr_de), ...
               singleton(u_disc, var_error_PN_T, curr_de), ...
               singleton(u_disc, var_error_zero_T, curr_de), ...
               singleton(u_disc, var_error_PP_T, curr_de), ...
               singleton(u_disc, var_error_GP_T, curr_de)];

        % Vetor vT: Segue exatamente a lógica out1 a out25 do seu loop
        vT = [vGNT, vPNT, vPNT, vPNT, vPPT, ... % out1-5
              vGNT, vPNT, vPNT, vZT,  vGPT, ... % out6-10
              vPNT, vPNT, vZT,  vPPT, vGNT, ... % out11-15
              vPNT, vZT,  vGPT, vGPT, vGPT, ... % out16-20
              vPPT, vGPT, vGPT, vGPT, vGPT];    % out21-25

        rt = [];
        for m = 1:5, for n = 1:5, rt = [rt, min(st(m), std(n))]; end; end
        Z_temp(i,j) = sum(rt .* vT) / (sum(rt) + (sum(rt)==0));

        % --- CÁLCULO PARA UMIDADE ---
        su = [singleton(u_disc, error_GN_U, curr_e), ...
              singleton(u_disc, error_PN_U, curr_e), ...
              singleton(u_disc, error_zero_U, curr_e), ...
              singleton(u_disc, error_PP_U, curr_e), ...
              singleton(u_disc, error_GP_U, curr_e)];

        sud = [singleton(u_disc, var_error_GN_U, curr_de), ...
               singleton(u_disc, var_error_PN_U, curr_de), ...
               singleton(u_disc, var_error_zero_U, curr_de), ...
               singleton(u_disc, var_error_PP_U, curr_de), ...
               singleton(u_disc, var_error_GP_U, curr_de)];

        % Vetor vU: Segue exatamente a lógica out1_U a out25_U do seu loop
        vU = [vGNU, vPNU, vPNU, vPNU, vPPU, ... % out1-5_U
              vGNU, vPNU, vPNU, vZU,  vGPU, ... % out6-10_U
              vPNU, vPNU, vZU,  vPPU, vGNU, ... % out11-15_U
              vPNU, vZU,  vGPU, vGPU, vGPU, ... % out16-20_U
              vZU,  vPPU, vGPU, vGPU, vGPU];    % out21-25_U

        ru = [];
        for m = 1:5, for n = 1:5, ru = [ru, min(su(m), sud(n))]; end; end
        Z_umid(i,j) = sum(ru .* vU) / (sum(ru) + (sum(ru)==0));
    end
end

% 3. Plotagem das superfícies
figure('Name', 'Superfícies de Controle Incubadora', 'Color', 'w');

% Temperatura
subplot(1,2,1);
surf(E, DE, Z_temp, 'EdgeColor', 'k', 'LineWidth', 0.1); 
title('Superfície: Temperatura (\Delta u_T)');
xlabel('Erro (e)'); ylabel('\Delta Erro (\Delta e)'); zlabel('\Delta u');
colormap('jet'); colorbar; grid on;
view(-45, 30);
caxis([vGNT vGPT]); % Ajusta escala para os limites da temperatura

% Umidade
subplot(1,2,2);
surf(E, DE, Z_umid, 'EdgeColor', 'k', 'LineWidth', 0.1);
title('Superfície: Umidade (\Delta u_U)');
xlabel('Erro (e)'); ylabel('\Delta Erro (\Delta e)'); zlabel('\Delta u');
colormap('jet'); colorbar; grid on;
view(-45, 30);
caxis([vGNU vGPU]); % Ajusta escala para os limites da umidade


% ========================================================================
% 7. PLOTAGEM DAS FUNÇÕES DE PERTINÊNCIA (ESCALA REAL)
% ========================================================================

% --- FIGURA 1: TEMPERATURA ---
figure('Name', 'Pertinência: Temperatura (Escala Real)', 'Color', 'w');
inv_eT = 1/Escala_eT;   % Converte de norm [-1,1] para °C
inv_deT = 1/Escala_deT; % Converte de norm [-1,1] para Δ°C

% Subplot 1: Erro em Graus Celsius
subplot(1,3,1); hold on;
funcoes_erro = {error_GN_T, error_PN_T, error_zero_T, error_PP_T, error_GP_T};
for i = 1:5
    plot(u_disc * inv_eT, funcoes_erro{i}, 'Color', cores{i}, 'LineWidth', 2.5);
end
title('Entrada: Erro (°C)'); xlabel('Erro [°C]'); ylabel('\mu'); grid on;
axis([-18 18 0 1])

% Subplot 2: Variação do Erro em Graus Celsius
subplot(1,3,2); hold on;
funcoes_var = {var_error_GN_T, var_error_PN_T, var_error_zero_T, var_error_PP_T, var_error_GP_T};
for i = 1:5
    plot(u_disc * inv_deT, funcoes_var{i}, 'Color', cores{i}, 'LineWidth', 2.5);
end
title('Entrada: \Delta Erro (°C)'); xlabel('\Delta Erro [°C]'); ylabel('\mu'); grid on;

% Subplot 3: Singletons de Saída (Escala Real)
subplot(1,3,3); hold on;
% Multiplicamos os valores dos singletons pela Escala_duT
x_coord_T_real = [vGNT, vPNT, vZT, vPPT, vGPT] * Escala_duT;
for i = 1:length(x_coord_T_real)
    stem(x_coord_T_real(i), 1, 'LineWidth', 2, 'Color', cores{i}, 'MarkerFaceColor', cores{i});
    text(x_coord_T_real(i), 1.1, labels{i}, 'Color', cores{i}, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
title(['Saída: \Delta u_T (Ganhos: ', num2str(Escala_duT), ')']);
xlabel('Incremento Real na Saída'); ylabel('\mu'); grid on;
axis([min(x_coord_T_real)-1, max(x_coord_T_real)+1, 0, 1.3]);


% --- FIGURA 2: UMIDADE ---
figure('Name', 'Pertinência: Umidade (Escala Real)', 'Color', 'w');
inv_eU = 1/Escala_eU;   % Converte de norm [-1,1] para %
inv_deU = 1/Escala_deU; % Converte de norm [-1,1] para Δ%

% Subplot 1: Erro em Porcentagem
subplot(1,3,1); hold on;
funcoes_erro_U = {error_GN_U, error_PN_U, error_zero_U, error_PP_U, error_GP_U};
for i = 1:5
    plot(u_disc * inv_eU, funcoes_erro_U{i}, 'Color', cores{i}, 'LineWidth', 2.5);
end
title('Entrada: Erro (%)'); xlabel('Erro [%]'); ylabel('\mu'); grid on;
axis([-15 15 0 1])
% Subplot 2: Variação do Erro em Porcentagem
subplot(1,3,2); hold on;
funcoes_var_U = {var_error_GN_U, var_error_PN_U, var_error_zero_U, var_error_PP_U, var_error_GP_U};
for i = 1:5
    plot(u_disc * inv_deU, funcoes_var_U{i}, 'Color', cores{i}, 'LineWidth', 2.5);
end
title('Entrada: \Delta Erro (%)'); xlabel('\Delta Erro [%]'); ylabel('\mu'); grid on;

% Subplot 3: Singletons de Saída (Escala Real)
subplot(1,3,3); hold on;
% Multiplicamos os valores dos singletons pela Escala_duU
x_coord_U_real = [vGNU, vPNU, vZU, vPPU, vGPU] * Escala_duU;
for i = 1:length(x_coord_U_real)
    stem(x_coord_U_real(i), 1, 'LineWidth', 2, 'Color', cores{i}, 'MarkerFaceColor', cores{i});
    text(x_coord_U_real(i), 1.1, labels{i}, 'Color', cores{i}, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
title(['Saída: \Delta u_U (Ganhos: ', num2str(Escala_duU), ')']);
xlabel('Incremento Real na Saída'); ylabel('\mu'); grid on;
axis([min(x_coord_U_real)-1, max(x_coord_U_real)+1, 0, 1.3]);


% ========================================================================
% GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) EM ESCALA REAL
% ========================================================================

figure('Name', 'Superfícies de Controle em Escala Real', 'Color', 'w');

% --- SUPERFÍCIE: TEMPERATURA ---
subplot(1,2,1);
% E e DE são as malhas normatizadas. Multiplicamos pelos inversos das escalas:
surf(E * (1/Escala_eT), DE * (1/Escala_deT), Z_temp * Escala_duT, 'EdgeColor', 'k', 'LineWidth', 0.1); 
title(['Superfície Real: Temperatura (\Delta u_T = ', num2str(Escala_duT), ')']);
xlabel('Erro (e) [°C]'); 
ylabel('\Delta Erro (\Delta e) [°C]'); 
zlabel('\Delta u Real');
colormap('jet'); colorbar; grid on;
view(-45, 30);
axis tight
% --- SUPERFÍCIE: UMIDADE ---
subplot(1,2,2);
% Aplicando os ganhos de escala da umidade nos eixos e na saída Z:
surf(E * (1/Escala_eU), DE * (1/Escala_deU), Z_umid * Escala_duU, 'EdgeColor', 'k', 'LineWidth', 0.1);
title(['Superfície Real: Umidade (\Delta u_U = ', num2str(Escala_duU), ')']);
xlabel('Erro (e) [%]'); 
ylabel('\Delta Erro (\Delta e) [%]'); 
zlabel('\Delta u Real');
colormap('jet'); colorbar; grid on;
view(-45, 30);


% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
clf(figure(4))
figure(4);
% temperatura
subplot(4, 2, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_1t, 'b', 'LineWidth', 2);
title('Saída de Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'Saída');
grid on;
subplot(4, 2, 3);
plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;

subplot(4, 2, 5);
plot(tempo/60, erro1,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
subplot(4, 2, 7);
plot(tempo/60, de1,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
% umidade
subplot(4, 2, 2);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_2u, 'b', 'LineWidth', 2);
title('Saída de Umidade');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída');
grid on;
subplot(4, 2, 4);
plot(tempo/60, u_2u, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;

subplot(4, 2, 6);
plot(tempo/60, erro2,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(4, 2, 8);
plot(tempo/60, de2,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;

% ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'planilhas/dados_FLC_TITO_patamares.csv';
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);

% ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
% % 
% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_1t = T_lida.Referencia_Temperatura;
% y_1t = T_lida.Saida_Temperatura;
% u_1t = T_lida.Sinal_Controle_Temperatura;
% erro1 = T_lida.Erro_Temperatura;
% r_2u= T_lida.Referencia_Umidade;
% y_2u = T_lida.Saida_Umidade;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro2 = T_lida.Erro_Umidade;
