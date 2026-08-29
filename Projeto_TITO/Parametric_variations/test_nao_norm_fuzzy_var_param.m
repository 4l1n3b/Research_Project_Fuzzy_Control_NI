%==========================================================================
% CONTROLADOR FUZZY P/ MODELO DE INCUBADORA
%==========================================================================
%%
clear; 
ganho = 1;
K = [2.89 -3.1 -4.22 22.222];
tau = [550 260 546 180];
% qtde_amostras = 3000;
qde_amostras = 900;
T_amostra = 18;
% Ganho estático
k11v = [2.804;
    3.144];

k12v = [-3.333;
    -3.131];

k21v = [-4.323;
    -4.293];

k22v = [20.923;
    21.339];

% Constante de tempo
tau11v = [546.802;
    520.354];

tau12v = [277.904;
    244.128];

tau21v = [516.071;
    510.041];

tau22v = [170.196;
    177.685];

%Atraso de transporte
Td11v = [53;60];
Td12v = [50;48];
Td21v = [98;100];
Td22v = [16;15];

%vetores para contabiliar as amostras de atraso de transporte
am_Td11 = [3,4];
am_Td12 = [3,3];
am_Td21 = [6,6];
am_Td22 = [1,1];

% Pré-alocação
num_mat = cell(2, 2); % Armazena num11, num12, num21, num22 para cada iteração
den_mat = cell(2, 2); % Armazena den11, den12, den21, den22 para cada iteração

%Loop para gerar a funcao de transferencia e discretia-las
for i=1:2
    Gs_11 = tf([k11v(i)], [tau11v(i) 1],'InputDelay',Td11v(i));
    Gs_12 = tf([k12v(i)*ganho], [tau12v(i) 1],'InputDelay',Td12v(i));
    Gs_21 = tf([k21v(i)], [tau21v(i) 1],'InputDelay',Td21v(i));
    Gs_22 = tf([k22v(i)*ganho], [tau22v(i) 1],'InputDelay',Td22v(i));
    T_amost = 18;
    Gz_11 = c2d(Gs_11, T_amost, 'zoh');
    Gz_12 = c2d(Gs_12, T_amost, 'zoh');
    Gz_21 = c2d(Gs_21, T_amost, 'zoh');
    Gz_22 = c2d(Gs_22, T_amost, 'zoh');

    % Extração e armazenamento nas Matrizes de Células
    [num_mat{i,1}, den_mat{i,1}] = tfdata(Gz_11, 'v');
    [num_mat{i,2}, den_mat{i,2}] = tfdata(Gz_12, 'v');
    [num_mat{i,3}, den_mat{i,3}] = tfdata(Gz_21, 'v');
    [num_mat{i,4}, den_mat{i,4}] = tfdata(Gz_22, 'v');

end
% ========================================================================
% % TEMPERATURE
% Escala_eT = 1/30;
% Escala_deT = 1/2;
% Escala_duT = 5;
% % HUMIDITY
% Escala_eU = 1/22;
% Escala_deU= 1/2;
% Escala_duU = 7;
% TEMPERATURE
Escala_eT = 1;
Escala_deT = 1;
Escala_duT = 1;
% HUMIDITY
Escala_eU = 1;
Escala_deU= 1;
Escala_duU = 1;

% % TEMPERATURE
% Escala_eT = 1/30;
% Escala_deT = 1/2; 
% Escala_duT = 5;
% % HUMIDITY
% Escala_eU = 1/22; 
% Escala_deU= 1/2; 
% Escala_duU = 7;
% %% Definir funcoes de pertinencia
% %Temperatura
%     % Universo de discurso (local)
%     u_disc = linspace(-1, 1, 10000);
%     % Defining membership functions (MP)
%     error_GN_T   = trapezoidal(u_disc, -2, -1, -.85, -0.7);
%     error_PN_T   = triangular(u_disc, -.9, -.7, 0);
%     error_zero_T  = triangular(u_disc, -.7, 0, .7);
%     error_PP_T   = triangular(u_disc, 0, .6, .8);
%     error_GP_T    = trapezoidal(u_disc, 0.5, .7, 1, 2);
% 
%     var_error_GN_T   = trapezoidal(u_disc, -2, -1, -.9, -0.5);
%     var_error_PN_T   = triangular(u_disc, -1, -.5, 0);
%     var_error_zero_T  = triangular(u_disc, -.5, 0, .5);
%     var_error_PP_T   = triangular(u_disc, 0, .5, 1);
%     var_error_GP_T    = trapezoidal(u_disc, 0.5, .9, 1, 2);
%     % Singletons de saida
%     vGPT   = 1; vPPT = .2; vZT = 0; vPNT = -.5; vGNT = -1;
% Definir funcoes de pertinencia
%Temperatura
% Universo de discurso (local)

%FUNCIONOU
u_disc_erro_temp = linspace(-22, 22, 10000);
% Defining membership functions (MP)
error_GN_T   = trapezoidal(u_disc_erro_temp, -23, -22, -21, -11);
error_PN_T   = triangular(u_disc_erro_temp, -22, -11, 0);
error_zero_T  = triangular(u_disc_erro_temp, -8, 0, 8);
error_PP_T   = triangular(u_disc_erro_temp, 0, 9, 22);
error_GP_T    = trapezoidal(u_disc_erro_temp, 9, 18, 22, 23);

u_disc_Derro_temp = linspace(-3, 3, 10000);
var_error_GN_T   = trapezoidal(u_disc_Derro_temp, -4, -3, -2.5, -1.5);
var_error_PN_T   = triangular(u_disc_Derro_temp, -3, -.8, 0);
var_error_zero_T  = triangular(u_disc_Derro_temp, -.9, 0, .9);
var_error_PP_T   = triangular(u_disc_Derro_temp, 0, 1, 3);
var_error_GP_T    = trapezoidal(u_disc_Derro_temp, 1, 2.3, 3, 4);
% Singletons de saida
vGPT   = 2.5; vPPT = 1.7; vZT = 0; vPNT = -1.9; vGNT = -2.4;

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
tamanho_font = 12;
figure(1);
clf(figure(1));
% --- Subplot 1: Erro ---
subplot(3,1,1)
hold on;
funcoes_erro = {error_GN_T, error_PN_T, error_zero_T, error_PP_T, error_GP_T};
for i = 1:5
    plot(u_disc_erro_temp, funcoes_erro{i}, 'Color', cores{i}, 'LineWidth', 3);
    % Encontra o valor máximo para posicionar a label no topo da função
    [max_val, idx] = max(funcoes_erro{i});
    text(u_disc_erro_temp(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
title('Input: Error', 'FontSize',14);
xlabel('Error');
ylabel('Membership Degree (\mu)');
axis([-22 22 0 1.2]); grid on; hold off;
% --- Subplot 2: Variação do Erro ---
subplot(3,1,2)
hold on;
funcoes_var = {var_error_GN_T, var_error_PN_T, var_error_zero_T, var_error_PP_T, var_error_GP_T};
for i = 1:5
    plot(u_disc_Derro_temp, funcoes_var{i}, 'Color', cores{i}, 'LineWidth', 3);
    [max_val, idx] = max(funcoes_var{i});
    text(u_disc_Derro_temp(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
title('Input: Error Variation', 'FontSize',14);
xlabel('Error Variation');
ylabel('Membership Degree (\mu)');
axis([-3 3 0 1.2]); grid on; hold off;
% --- Subplot 3: Saída (Singletons) ---
subplot(3,1,3)
x_coord = [vGNT, vPNT, vZT, vPPT, vGPT];
y_coord = ones(1, 5);
hold on;
for i = 1:length(x_coord)
    stem(x_coord(i), y_coord(i), 'LineWidth', 3, 'Color', cores{i}, ...
        'MarkerFaceColor', cores{i}, 'Marker', 'o', 'MarkerSize', 6);

    text(x_coord(i), 1.1, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
set(gca, 'XTick', x_coord, 'XTickLabel', x_coord);
title('Output: Control Signal Variation', 'FontSize',14);
xlabel('Singleton Value');
ylabel('Membership Degree (\mu)');
axis([-3 3 0 1.25]); grid on; hold off;


%%Umidade
% Universo de discurso (local para a função)
u_disc_erro_umid = linspace(-25, 25, 10000);
% Defining membership functions (MP)
error_GN_U   = trapezoidal(u_disc_erro_umid, -26, -25, -21.7, -12.5);
error_PN_U   = triangular(u_disc_erro_umid, -22.8, -12, 0);
error_zero_U  = triangular(u_disc_erro_umid, -15, 0, 15);
error_PP_U   = triangular(u_disc_erro_umid, 0, 9, 22.8);
error_GP_U    = trapezoidal(u_disc_erro_umid, 12.5, 21.7, 25, 26);

u_disc_Derro_umid = linspace(-7, 7, 10000);
var_error_GN_U   = trapezoidal(u_disc_Derro_umid, -8, -7, -5, -3.5);
var_error_PN_U   = triangular(u_disc_Derro_umid, -7, -4, 0);
var_error_zero_U  = triangular(u_disc_Derro_umid, -2, 0, 2);
var_error_PP_U   = triangular(u_disc_Derro_umid, 0, 2, 7);
var_error_GP_U    = trapezoidal(u_disc_Derro_umid, 3.5, 5, 7, 8);
% Singletons de saida
vGPU = 1.1; vPPU = .5; vZU = 0; vPNU = -1; vGNU = -1.5;

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
clf(figure(2));
% --- Subplot 1: Erro (_U) ---
subplot(3,1,1)
hold on;
funcoes_erro_U = {error_GN_U, error_PN_U, error_zero_U, error_PP_U, error_GP_U};
for i = 1:5
    plot(u_disc_erro_umid, funcoes_erro_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    % Posicionamento automático da label no topo de cada função
    [max_val, idx] = max(funcoes_erro_U{i});
    text(u_disc_erro_umid(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
title('Input: Error', 'FontSize',16);
xlabel('Error');
ylabel('Membership Degree (\mu)');
axis([-25 25 0 1.2]); grid on; hold off;
% --- Subplot 2: Variação do Erro (_U) ---
subplot(3,1,2)
hold on;
funcoes_var_U = {var_error_GN_U, var_error_PN_U, var_error_zero_U, var_error_PP_U, var_error_GP_U};
for i = 1:5
    plot(u_disc_Derro_umid, funcoes_var_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    [max_val, idx] = max(funcoes_var_U{i});
    text(u_disc_Derro_umid(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
title('Input: Error Variation', 'FontSize',16);
xlabel('Error Variation');
ylabel('Membership Degree (\mu)');
axis([-7 7 0 1.2]); grid on; hold off;
% --- Subplot 3: Saída (Singletons _U) ---
subplot(3,1,3)
x_coord_U = [vGNU, vPNU, vZU, vPPU, vGPU];
y_coord_U = ones(1, 5);
hold on;
for i = 1:length(x_coord_U)
    stem(x_coord_U(i), y_coord_U(i), 'LineWidth', 3, 'Color', cores{i}, ...
        'MarkerFaceColor', cores{i}, 'Marker', 'o', 'MarkerSize', 6);

    text(x_coord_U(i), 1.1, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', tamanho_font);
end
set(gca, 'XTick', x_coord_U, 'XTickLabel', x_coord_U);
title('Output: Control Signal Variation', 'FontSize',16);
xlabel('Singleton Value');
ylabel('Membership Degree (\mu)');
axis([-2 2 0 1.25]); grid on; hold off;


% amostras = [300 600 900 1200 1500 1800 2400 2700 3000];

amostras = [300 600 900];

%% 3. LOOP DE SIMULAÇÃO PARA CADA CASO PARAMÉTRICO

for i = 1:3
% i = 3;
    % INICIALIZAÇÕES
    r_1t = zeros(1, qde_amostras);
    r_2u = zeros(1, qde_amostras);
    y_1t = zeros(1, qde_amostras);
    y_2u = zeros(1, qde_amostras);
    u_1t = zeros(1, qde_amostras);
    u_2u = zeros(1, qde_amostras);
    y_11t = zeros(1, qde_amostras);
    y_12u = zeros(1, qde_amostras);
    y_21t = zeros(1, qde_amostras);
    y_22u = zeros(1, qde_amostras);
    erro1 = zeros(1, qde_amostras);
    erro2 = zeros(1, qde_amostras);
    de1 = zeros(1, qde_amostras);
    de2 = zeros(1, qde_amostras);
    % tempo = zeros(1, qtde_amostras);
    % DEFININDO OS PATAMARES DE CADA ENTRADA
    r_1t(1:amostras(1)) = 30;
    r_1t((amostras(1)+1):(amostras(2))) = 36;
    r_1t((amostras(2)+1):amostras(3)) = 36;
    % r_1t((amostras(3)+1):amostras(4)) = 37.5;
    % r_1t((amostras(4)+1):amostras(5)) = 37.5;
    % r_1t((amostras(5)+1):amostras(6)) = 35;
    % r_1t((amostras(6)+1):amostras(7)) = 35;
    % r_1t((amostras(7)+1):amostras(8)) = 34;
    % r_1t((amostras(8)+1):amostras(9)) = 34;

    r_2u(1:amostras(1)) = 55;
    r_2u((amostras(1)+1):(amostras(2))) = 55;
    r_2u((amostras(2)+1):amostras(3)) = 65;
    % r_2u((amostras(3)+1):amostras(4)) = 55;
    % r_2u((amostras(4)+1):amostras(5)) = 65;
    % r_2u((amostras(5)+1):amostras(6)) = 65;
    % r_2u((amostras(6)+1):amostras(7)) = 85;
    % r_2u((amostras(7)+1):amostras(8)) = 85;
    % r_2u((amostras(8)+1):amostras(9)) = 85;
    tempo = 0:T_amostra:(qde_amostras-1)*T_amostra;

    y_1t_inicial = 22; y_2u_inicial = 50;
    %% 1. EXTRAÇÃO DOS DADOS DA MATRIZ (CELL ARRAY)
    % Acessa os coeficientes da variação paramétrica 'i'
    if i ~= 3
        n11 = num_mat{i,1}; d11 = den_mat{i,1};
        n12 = num_mat{i,2}; d12 = den_mat{i,2};
        n21 = num_mat{i,3}; d21 = den_mat{i,3};
        n22 = num_mat{i,4}; d22 = den_mat{i,4};
        cont = am_Td21(i)+2;
    else
        cont = 8;
    end
    % Condições iniciais (1 a 7)
    for k = 1:7
        y_1t(k) = y_1t_inicial;
        y_2u(k) = y_2u_inicial;
        erro1(k) = r_1t(k) - y_1t(k);
        de1(k) = 0;
        erro2(k) = r_2u(k) - y_2u(k);
        de2(k) = 0;
        tempo(k) = (k) * T_amostra;
    end

    %% LOOP DE CONTROLE
    for k = cont:qde_amostras
        if i == 3
            y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
            y_12u(k) = 0.9331 * y_12u(k-1) - 0.03556 * u_2u(k-3) - 0.1718 * u_2u(k-4);
            y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
            y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);

        else
            % Usamos d11(2) pois d11(1) é sempre 1.
            % n11(end-1) e n11(end) garantem o acesso aos coeficientes ativos.
            y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*u_1t(k-am_Td11(i)) + n11(2)*u_1t(k-am_Td11(i)-1);

            % Bloco 12: r2 -> y1
            y_12u(k) = -d12(2)*y_12u(k-1) + n12(1)*u_2u(k-am_Td12(i)) + n12(2)*u_2u(k-am_Td12(i)-1);

            % Bloco 21: r1 -> y2
            y_21t(k) = -d21(2)*y_21t(k-1) + n21(1)*u_1t(k-am_Td21(i)) + n21(2)*u_1t(k-am_Td21(i)-1);

            % Bloco 22: r2 -> y2
            y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*u_2u(k-am_Td22(i)) + n22(2)*u_2u(k-am_Td22(i)-1);
        end
        % Saída Combinada
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
        s1 = singleton(u_disc_erro_temp, error_GN_T, e1_fuzzy);
        s2 = singleton(u_disc_erro_temp, error_PN_T, e1_fuzzy);
        s3 = singleton(u_disc_erro_temp, error_zero_T, e1_fuzzy);
        s4 = singleton(u_disc_erro_temp, error_PP_T, e1_fuzzy);
        s5 = singleton(u_disc_erro_temp, error_GP_T, e1_fuzzy);

        s6 = singleton(u_disc_Derro_temp, var_error_GN_T, de1_fuzzy);
        s7 = singleton(u_disc_Derro_temp, var_error_PN_T, de1_fuzzy);
        s8 = singleton(u_disc_Derro_temp, var_error_zero_T, de1_fuzzy);
        s9 = singleton(u_disc_Derro_temp, var_error_PP_T, de1_fuzzy);
        s10 = singleton(u_disc_Derro_temp, var_error_GP_T, de1_fuzzy);

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
        out21 = r21 * vPPT; out22 = r22 * vPPT; out23 = r23 * vGPT; out24 = r24 * vGPT; out25 = r25 * vGPT;
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
        s1 = singleton(u_disc_erro_umid, error_GN_U, e2_fuzzy);
        s2 = singleton(u_disc_erro_umid, error_PN_U, e2_fuzzy);
        s3 = singleton(u_disc_erro_umid, error_zero_U, e2_fuzzy);
        s4 = singleton(u_disc_erro_umid, error_PP_U, e2_fuzzy);
        s5 = singleton(u_disc_erro_umid, error_GP_U, e2_fuzzy);

        s6 = singleton(u_disc_Derro_umid, var_error_GN_U, de2_fuzzy);
        s7 = singleton(u_disc_Derro_umid, var_error_PN_U, de2_fuzzy);
        s8 = singleton(u_disc_Derro_umid, var_error_zero_U, de2_fuzzy);
        s9 = singleton(u_disc_Derro_umid, var_error_PP_U, de2_fuzzy);
        s10 = singleton(u_disc_Derro_umid, var_error_GP_U, de2_fuzzy);
        % Regras e Implicação (Mamdani/Singleton)
        r1U = min(s1, s6);  out1_U = r1U * vGNU;
        r2U = min(s1, s7);  out2_U = r2U * vPNU;
        r3U = min(s1, s8);  out3_U = r3U * vPNU;
        r4U = min(s1, s9);  out4_U = r4U * vPNU;
        r5U = min(s1, s10); out5_U = r5U * vZU;

        r6U = min(s2, s6);  out6_U = r6U * vGNU;
        r7U = min(s2, s7);  out7_U = r7U * vPNU;
        r8U = min(s2, s8);  out8_U = r8U * vPNU;
        r9U = min(s2, s9);  out9_U = r9U * vZU;
        r10U = min(s2, s10); out10_U = r10U * vPPU;

        r11U = min(s3, s6);  out11_U = r11U * vPNU;
        r12U = min(s3, s7);  out12_U = r12U * vPNU;
        r13U = min(s3, s8);  out13_U = r13U * vZU;
        r14U = min(s3, s9);  out14_U = r14U * vPPU;
        r15U = min(s3, s10); out15_U = r15U * vPPU;

        r16U = min(s4, s6);  out16_U = r16U * vPPU;
        r17U = min(s4, s7);  out17_U = r17U * vPPU;
        r18U = min(s4, s8);  out18_U = r18U * vPPU;
        r19U = min(s4, s9);  out19_U = r19U * vPPU;
        r20U = min(s4, s10); out20_U = r20U * vGPU;

        r21U = min(s5, s6);  out21_U = r21U * vPPU;
        r22U = min(s5, s7);  out22_U = r22U * vPPU;
        r23U = min(s5, s8);  out23_U = r23U * vPPU;
        r24U = min(s5, s9);  out24_U = r24U * vPPU;
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

% % ----------------------------------------------------
% % 7. PLOTAGEM DOS RESULTADOS
% % ----------------------------------------------------
% clf(figure(4))
% figure(4);
% %temperatura
% subplot(4, 2, 1);
% plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5);
% hold on;
% plot(tempo/60, y_1t, 'b', 'LineWidth', 2);
% title('Saída de Temperatura');
% xlabel('Tempo (min)');
% ylabel('Temperatura (°C)');
% legend('Referência', 'Saída');
% grid on;
% subplot(4, 2, 3);
% plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
% title('Sinal de Controle (u)');
% xlabel('Tempo (min)');
% ylabel('Temperatura (°C)');
% grid on;
% 
% subplot(4, 2, 5);
% plot(tempo/60, erro1,'b', 'LineWidth', 1.5);
% title('Erro (e)');
% xlabel('Tempo (min)');
% ylabel('Temperatura (°C)');
% grid on;
% subplot(4, 2, 7);
% plot(tempo/60, de1,'r', 'LineWidth', 1.5);
% title('Variação do Erro (de)');
% xlabel('Tempo (min)');
% ylabel('Temperatura (°C)');
% grid on;
% %umidade
% subplot(4, 2, 2);
% plot(tempo/60, r_2u, 'r--', 'LineWidth', 1.5);
% hold on;
% plot(tempo/60, y_2u, 'b', 'LineWidth', 2);
% title('Saída de Umidade');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% legend('Referência', 'Saída');
% grid on;
% subplot(4, 2, 4);
% plot(tempo/60, u_2u, 'g', 'LineWidth', 2);
% title('Sinal de Controle (u)');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% grid on;
% 
% subplot(4, 2, 6);
% plot(tempo/60, erro2,'b', 'LineWidth', 1.5);
% title('Erro (e)');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% grid on;
% subplot(4, 2, 8);
% plot(tempo/60, de2,'r', 'LineWidth', 1.5);
% title('Variação do Erro (de)');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% grid on;
% 4. SALVAR DADOS (Mantendo sua estrutura Switch/Case)
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', ...
        'Saida_Umidade', 'Controle_Temperatura', 'Controle_Umidade', 'Erro_Temperatura', 'Erro_Umidade'});
    switch i
        case 1
            filename = 'Tables/Fuzzy/incubadora_var_param1Fuzzy.csv';
        case 2
            filename = 'Tables/Fuzzy/incubadora_var_param2Fuzzy.csv';
        otherwise
            filename = 'Tables/Fuzzy/incubadora_var_param100Fuzzy.csv';
    end
    if ~exist('Tables', 'dir'), mkdir('Tables'); end
    writetable(T, filename);
    disp(['Arquivo salvo: ' filename]);
end
%==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'planilhas/dados_FLC_TITO_patamares_nao_norm.csv';
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);



