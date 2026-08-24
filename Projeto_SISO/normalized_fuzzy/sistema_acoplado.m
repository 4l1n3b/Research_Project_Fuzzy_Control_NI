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

%% ========================================================================

% %Universo de discurso
% error_t = linspace(-1, 1, 10000);
% d_error_t = linspace(-1, 1, 10000);
% %d_control_t = linspace(-1, 1, 10000);
% error_u = linspace(-1, 1, 10000);
% d_error_u = linspace(-1, 1, 10000);
% 
% %Normalização - Temperatura
% Escala_eT = 1/20;
% Escala_deT = 1/5; 
% Escala_duT = 7;
% %Normalização - Umidade
% Escala_eU = 1/20;
% Escala_deU = 1/5; 
% Escala_duU = 7;
% 
% % Membership Functions
% %TEMPERATURE
% error_GN_T   = trapezoidal(error_t, -1, -1, -.85, -0.7);
% error_PN_T   = triangular(error_t, -.9, -.7, 0);
% error_zero_T  = triangular(error_t, -.6, 0, .6);
% error_PP_T   = triangular(error_t, 0, .7, .9);
% error_GP_T    = trapezoidal(error_t, 0.7, .85, 1, 1);
% 
% var_error_GN_T   = trapezoidal(d_error_t, -1, -1, -.9, -0.5);
% var_error_PN_T   = triangular(d_error_t, -1, -.5, 0);
% var_error_zero_T  = triangular(d_error_t, -.6, 0, .6);
% var_error_PP_T   = triangular(d_error_t, 0, .5, 1);
% var_error_GP_T    = trapezoidal(d_error_t, 0.5, .9, 1, 1);
% 
% %usando singletons como MP de saida
% var_control_GP_T   = 1.5;  % Muito frio
% var_control_PP_T   = .2;  % Pouco frio
% var_control_zero_T  = 0;
% var_control_PN_T   = -.5; % Pouco quente
% var_control_GN_T    = -1; % Muito quente
% 
% % Gráficos
% figure;
% plot(error_t, error_GN_T, error_t, error_PN_T, error_t, error_zero_T, error_t, error_PP_T,error_t, error_GP_T, 'LineWidth', 3);
% legend('GN', 'PN', 'zero', 'PP', 'GP');
% title('Entrada: Erro');
% xlabel('Erro nromaliado');
% axis([-1 1 0 1]);
% grid on;
% 
% figure;
% plot(d_error_t, var_error_GN_T, d_error_t, var_error_PN_T, d_error_t, var_error_zero_T, d_error_t, var_error_PP_T,d_error_t, var_error_GP_T, 'LineWidth', 3);
% legend('GN', 'PN', 'zero', 'PP', 'GP');
% title('Entrada: Variaçao do Erro');
% xlabel('Variaçao do Erro nromaliado');
% axis([-1 1 0 1]);
% grid on;
% 
% % --- Gráfico de Saída (Singletons) ---
% figure;
% 
% x_coord = [var_control_GN_T, var_control_PN_T, var_control_zero_T, var_control_PP_T, var_control_GP_T];
% y_coord = [1, 1, 1, 1, 1]; % Representa o grau de pertinência máximo (1.0)
% 
% h = stem(x_coord, y_coord, 'LineWidth', 3, 'MarkerFaceColor', 'auto');
% legend('Singletons de Saída (\Delta u)');
% 
% % Ajuste dos nomes nos eixos para facilitar a leitura
% set(gca, 'XTick', x_coord);
% set(gca, 'XTickLabel', {'GN', 'PN', 'zero', 'PP', 'GP'});
% 
% title('Saída: Variação do Sinal de Controle (Singletons)');
% 
% axis([-1.5 2 0 1.2]); 
% grid on;
% 
% %HUMITIDY
% error_GN_U   = trapezoidal(error_u, -1, -1, -.85, -0.7);
% error_PN_U   = triangular(error_u, -.9, -.7, 0);
% error_zero_U  = triangular(error_u, -.6, 0, .6);
% error_PP_U   = triangular(error_u, 0, .7, .9);
% error_GP_U    = trapezoidal(error_u, 0.7, .85, 1, 1);
% 
% var_error_GN_U   = trapezoidal(error_u, -1, -1, -.7, -0.5);
% var_error_PN_U   = triangular(error_u, -1, -.5, 0);
% var_error_zero_U  = triangular(error_u, -.6, 0, .6);
% var_error_PP_U   = triangular(error_u, 0, .5, 1);
% var_error_GP_U    = trapezoidal(error_u, 0.5, .7, 1, 1);
% 
% %usando singletons como MP de saida
% var_control_GP_U   = 1.5;  % Muito frio
% var_control_PP_U   = .2;  % Pouco frio
% var_control_zero_U  = 0;
% var_control_PN_U   = -.5; % Pouco quente
% var_control_GN_U    = -1; % Muito quente
% % var_control_GN   = trapezoidal(error, -1, -1, -.9, -0.5);
% % var_control_PN   = triangular(error, -1, -.5, 0);
% % var_control_zero  = triangular(error, -.5, 0, .5);
% % var_control_PP   = triangular(error, 0, .5, 1);
% % var_control_GP    = trapezoidal(error, 0.5, .9, 1, 1);
% % Gráficos
% figure;
% plot(error_u, error_GN_U, error_u, error_PN_U, error_u, error_zero_U, error_u, error_PP_U,error_u, error_GP_U, 'LineWidth', 3);
% legend('GN', 'PN', 'zero', 'PP', 'GP');
% title('Entrada: Erro');
% xlabel('Erro nromaliado');
% axis([-1 1 0 1]);
% grid on;
% 
% figure;
% plot(d_error_u, var_error_GN_U, d_error_u, var_error_PN_U, d_error_u, var_error_zero_U, d_error_u, var_error_PP_U,d_error_u, var_error_GP_U, 'LineWidth', 3);
% legend('GN', 'PN', 'zero', 'PP', 'GP');
% title('Entrada: Variaçao do Erro');
% xlabel('Variaçao do Erro nromaliado');
% axis([-1 1 0 1]);
% grid on;
% 
% % --- Gráfico de Saída (Singletons) ---
% figure;
% 
% x_coord = [var_control_GN_U, var_control_PN_U, var_control_zero_U, var_control_PP_U, var_control_GP_U];
% y_coord = [1, 1, 1, 1, 1]; % Representa o grau de pertinência máximo (1.0)
% 
% h = stem(x_coord, y_coord, 'LineWidth', 3, 'MarkerFaceColor', 'auto');
% legend('Singletons de Saída (\Delta u)');
% 
% % Ajuste dos nomes nos eixos para facilitar a leitura
% set(gca, 'XTick', x_coord);
% set(gca, 'XTickLabel', {'GN', 'PN', 'zero', 'PP', 'GP'});
% 
% title('Saída: Variação do Sinal de Controle (Singletons)');
% xlabel('Valor do Singleton (Normalizado)');
% ylabel('Grau de Pertinência (\mu)');
% 
% axis([-1.5 2 0 1.2]); 
% grid on;
% TEMPERATURE
Escala_eT = 1/20;
Escala_deT = 1/5; 
Escala_duT = 7;

% HUMIDITY
Escala_eU = 1/20;
Escala_deU= 1/2; 
Escala_duU = 5;
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
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);
    
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
    
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


    % ================================================
    du1_f(k) = ctrl_fuzzy_temp(e1_fuzzy,de1_fuzzy);
    du2_f(k) = ctrl_fuzzy_hum(e2_fuzzy, de2_fuzzy);
    
    du1(k) = Escala_duT*du1_f(k);
    du2(k) = Escala_duU*du2_f(k);
    u_1t(k) = u_1t(k-1) + du1(k);
    u_2u(k) = u_2u(k-1) + du2(k);

    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
   if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
 
end

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

% % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'planilhas/dados_FLC_TITO_degrau.csv';
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
% =========================================================================
%Controladores de cada malha

% Temperatura

function du_out = ctrl_fuzzy_temp(e_fuzzy, de_fuzzy)
    % Universo de discurso (local)
    error_t = linspace(-1, 1, 10000);
    d_error_t = linspace(-1, 1, 10000);

    % Defining membership functions (MP)
    error_GN_T   = trapezoidal(error_t, -1, -1, -.85, -0.7);
    error_PN_T   = triangular(error_t, -.9, -.7, 0);
    error_zero_T  = triangular(error_t, -.6, 0, .6);
    error_PP_T   = triangular(error_t, 0, .7, .9);
    error_GP_T    = trapezoidal(error_t, 0.7, .85, 1, 1);
    
    var_error_GN_T   = trapezoidal(d_error_t, -1, -1, -.9, -0.5);
    var_error_PN_T   = triangular(d_error_t, -1, -.5, 0);
    var_error_zero_T  = triangular(d_error_t, -.6, 0, .6);
    var_error_PP_T   = triangular(d_error_t, 0, .5, 1);
    var_error_GP_T    = trapezoidal(d_error_t, 0.5, .9, 1, 1);

    % Singletons de saida
    var_control_GP_T   = 1.5; vPP = .2; vZ = 0; vPN = -.5; vGN = -1;

    % Fuzzificação
    s1 = singleton(error_t, error_GN_T, e_fuzzy);
    s2 = singleton(error_t, error_PN_T, e_fuzzy);
    s3 = singleton(error_t, error_zero_T, e_fuzzy);
    s4 = singleton(error_t, error_PP_T, e_fuzzy);
    s5 = singleton(error_t, error_GP_T, e_fuzzy);
    
    s6 = singleton(d_error_t, var_error_GN_T, de_fuzzy);
    s7 = singleton(d_error_t, var_error_PN_T, de_fuzzy);
    s8 = singleton(d_error_t, var_error_zero_T, de_fuzzy);
    s9 = singleton(d_error_t, var_error_PP_T, de_fuzzy); 
    s10 = singleton(d_error_t, var_error_GP_T, de_fuzzy); 
    
    % Regras
    r1 = min(s1, s6); r2 = min(s1, s7); r3 = min(s1, s8); r4 = min(s1, s9); r5 = min(s1, s10);
    r6 = min(s2, s6); r7 = min(s2, s7); r8 = min(s2, s8); r9 = min(s2, s9); r10 = min(s2, s10);
    r11 = min(s3, s6); r12 = min(s3, s7); r13 = min(s3, s8); r14 = min(s3, s9); r15 = min(s3, s10);
    r16 = min(s4, s6); r17 = min(s4, s7); r18 = min(s4, s8); r19 = min(s4, s9); r20 = min(s4, s10);
    r21 = min(s5, s6); r22 = min(s5, s7); r23 = min(s5, s8); r24 = min(s5, s9); r25 = min(s5, s10);
    
    % Implicação
    out1 = r1 * vGN; out2 = r2 * vPN; out3 = r3 * vPN; out4 = r4 * vPN; out5 = r5 * vPP;
    out6 = r6 * vGN; out7 = r7 * vPN; out8 = r8 * vPN; out9 = r9 * vZ; out10 = r10 * var_control_GP_T;
    out11 = r11 * vPN; out12 = r12 * vPN; out13 = r13 * vZ; out14 = r14 * vPP; out15 = r15 * vGN;
    out16 = r16 * vPN; out17 = r17 * vZ; out18 = r18 * vPP; out19 = r19 * var_control_GP_T; out20 = r20 * var_control_GP_T;
    out21 = r21 * vZ; out22 = r22 * var_control_GP_T; out23 = r23 * var_control_GP_T; out24 = r24 * var_control_GP_T; out25 = r25 * var_control_GP_T;

    % Agregação e Média Ponderada
    sum_weight = (r1+r2+r3+r4+r5+r6+r7+r8+r9+r10+r11+r12+r13+r14+r15+r16+r17+r18+r19+r20+r21+r22+r23+r24+r25);
    if sum_weight > 0
        sum_out = (out1+out2+out3+out4+out5+out6+out7+out8+out9+out10+out11+out12+out13+out14+out15+out16+out17+out18+out19+out20+out21+out22+out23+out24+out25);
        du_out = sum_out/ sum_weight;
    else
        du_out = 0;
    end
end

% Umidade
function du_outU = ctrl_fuzzy_hum(e_fuzzy, de_fuzzy)
    % Universo de discurso (local para a função)
    u_disc = linspace(-1, 1, 10000);

    % Defining membership functions (MP)
    error_GN_U   = trapezoidal(u_disc, -1, -1, -.85, -0.7);
    error_PN_U   = triangular(u_disc, -.9, -.7, 0);
    error_zero_U  = triangular(u_disc, -.6, 0, .6);
    error_PP_U   = triangular(u_disc, 0, .7, .9);
    error_GP_U    = trapezoidal(u_disc, 0.5, .7, 1, 1);
    
    var_error_GN_U   = trapezoidal(u_disc, -1, -1, -.7, -0.5);
    var_error_PN_U   = triangular(u_disc, -1, -.5, 0);
    var_error_zero_U  = triangular(u_disc, -.6, 0, .6);
    var_error_PP_U   = triangular(u_disc, 0, .5, 1);
    var_error_GP_U    = trapezoidal(u_disc, 0.5, .7, 1, 1);

    % Singletons de saida
    vGP = 1.5; vPP = .2; vZ = 0; vPN = -.5; vGN = -1;

    % Fuzzificação
    s1 = singleton(u_disc, error_GN_U, e_fuzzy);
    s2 = singleton(u_disc, error_PN_U, e_fuzzy);
    s3 = singleton(u_disc, error_zero_U, e_fuzzy);
    s4 = singleton(u_disc, error_PP_U, e_fuzzy);
    s5 = singleton(u_disc, error_GP_U, e_fuzzy);
    
    s6 = singleton(u_disc, var_error_GN_U, de_fuzzy);
    s7 = singleton(u_disc, var_error_PN_U, de_fuzzy);
    s8 = singleton(u_disc, var_error_zero_U, de_fuzzy);
    s9 = singleton(u_disc, var_error_PP_U, de_fuzzy); 
    s10 = singleton(u_disc, var_error_GP_U, de_fuzzy); 

    % Regras e Implicação (Mamdani/Singleton)
    r1U = min(s1, s6);  out1_U = r1U * vGN;
    r2U = min(s1, s7);  out2_U = r2U * vPN;
    r3U = min(s1, s8);  out3_U = r3U * vPN;
    r4U = min(s1, s9);  out4_U = r4U * vPN;
    r5U = min(s1, s10); out5_U = r5U * vPP;
    
    r6U = min(s2, s6);  out6_U = r6U * vGN;
    r7U = min(s2, s7);  out7_U = r7U * vPN;
    r8U = min(s2, s8);  out8_U = r8U * vPN;
    r9U = min(s2, s9);  out9_U = r9U * vZ;
    r10U = min(s2, s10); out10_U = r10U * vGP;
    
    r11U = min(s3, s6);  out11_U = r11U * vPN;
    r12U = min(s3, s7);  out12_U = r12U * vPN;
    r13U = min(s3, s8);  out13_U = r13U * vZ;
    r14U = min(s3, s9);  out14_U = r14U * vPP;
    r15U = min(s3, s10); out15_U = r15U * vGN;
    
    r16U = min(s4, s6);  out16_U = r16U * vPN;
    r17U = min(s4, s7);  out17_U = r17U * vZ;
    r18U = min(s4, s8);  out18_U = r18U * vGP;
    r19U = min(s4, s9);  out19_U = r19U * vGP;
    r20U = min(s4, s10); out20_U = r20U * vGP;
    
    r21U = min(s5, s6);  out21_U = r21U * vZ;
    r22U = min(s5, s7);  out22_U = r22U * vPP;
    r23U = min(s5, s8);  out23_U = r23U * vGP;
    r24U = min(s5, s9);  out24_U = r24U * vGP;
    r25U = min(s5, s10); out25_U = r25U * vGP;

    % Agregação e Defuzzificação (Média Ponderada)
    sum_weightU = (r1U+r2U+r3U+r4U+r5U+r6U+r7U+r8U+r9U+r10U+r11U+r12U+r13U+r14U+r15U+r16U+r17U+r18U+r19U+r20U+r21U+r22U+r23U+r24U+r25U);
    
    if sum_weightU > 0
        sum_outU = (out1_U+out2_U+out3_U+out4_U+out5_U+out6_U+out7_U+out8_U+out9_U+out10_U+out11_U+out12_U+out13_U+out14_U+out15_U+out16_U+out17_U+out18_U+out19_U+out20_U+out21_U+out22_U+out23_U+out24_U+out25_U);
        du_outU = sum_outU/ sum_weightU;
    else
        du_outU = 0;
    end
end


