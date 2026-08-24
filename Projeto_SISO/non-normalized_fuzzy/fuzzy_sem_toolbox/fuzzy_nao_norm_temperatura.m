%==========================================================================
% CONTROLADOR FUZZY P/ MODELO DE INCUBADORA - APENAS TEMPERATURA DESACOPLADA
%==========================================================================
clear; 
ganho = 0.1;
qde_amostras = 900;
T_amostra = 18;

% Ganho estático (Temperatura desacoplada)
k11v = [2.804; 3.144];

% Constante de tempo
tau11v = [546.802; 520.354];

% Atraso de transporte
Td11v = [53; 60];

% Vetor de atraso em número de amostras
am_Td11 = [3, 4];

% Pré-alocação
num_mat = cell(2, 1);
den_mat = cell(2, 1);

% Discretização das funções de transferência paramétricas (Modelos 1 e 2)
for i = 1:2
    Gs_11 = tf([k11v(i)], [tau11v(i) 1], 'InputDelay', Td11v(i));
    Gz_11 = c2d(Gs_11, T_amostra, 'zoh');
    [num_mat{i,1}, den_mat{i,1}] = tfdata(Gz_11, 'v');
end

% Escalas do Controlador
Escala_eT = 1;
Escala_deT = 1;
Escala_duT = 1;

%% FUNÇÕES DE PERTINÊNCIA - TEMPERATURA
% u_disc_erro_temp = linspace(-22, 22, 10000);
% error_GN_T   = trapezoidal(u_disc_erro_temp, -23, -22, -15, -6);
% error_PN_T   = triangular(u_disc_erro_temp, -22, -6, 0);
% error_zero_T  = triangular(u_disc_erro_temp, -8, 0, 8);
% error_PP_T   = triangular(u_disc_erro_temp, 0, 9, 22);
% error_GP_T    = trapezoidal(u_disc_erro_temp, 7, 15, 22, 23);
% 
% u_disc_Derro_temp = linspace(-3, 3, 10000);
% var_error_GN_T   = trapezoidal(u_disc_Derro_temp, -4, -3, -2, -.8);
% var_error_PN_T   = triangular(u_disc_Derro_temp, -3, -.6, 0);
% var_error_zero_T  = triangular(u_disc_Derro_temp, -.5, 0, .5);
% var_error_PP_T   = triangular(u_disc_Derro_temp, 0, .5, 3);
% var_error_GP_T    = trapezoidal(u_disc_Derro_temp, .7, 1.5, 3, 4);
% 
%Singletons de saída
%vGPT = 2.2; vPPT = 1.9; vZT = 0; vPNT = -1.3; vGNT = -1.8;
%FUNCIONOU
u_disc_erro_temp = linspace(-22, 22, 10000);
% Defining membership functions (MP)
error_GN_T   = trapezoidal(u_disc_erro_temp, -23, -22, -21, -11);
error_PN_T   = triangular(u_disc_erro_temp, -22, -11, 0);
error_zero_T  = triangular(u_disc_erro_temp, -9, 0, 9);
error_PP_T   = triangular(u_disc_erro_temp, 0, 9, 22);
error_GP_T    = trapezoidal(u_disc_erro_temp, 9, 18, 22, 23);

u_disc_Derro_temp = linspace(-3, 3, 10000);
var_error_GN_T   = trapezoidal(u_disc_Derro_temp, -4, -3, -2.5, -1.5);
var_error_PN_T   = triangular(u_disc_Derro_temp, -3, -.5, 0);
var_error_zero_T  = triangular(u_disc_Derro_temp, -.8, 0, .8);
var_error_PP_T   = triangular(u_disc_Derro_temp, 0, 1, 3);
var_error_GP_T    = trapezoidal(u_disc_Derro_temp, 1, 2.3, 3, 4);
% Singletons de saida
vGPT   = 2.1; vPPT = 1; vZT = 0; vPNT = -1.5; vGNT = -2;



%% PLOTAGEM DAS FUNÇÕES DE PERTINÊNCIA
cores = {
    [0.85, 0.33, 0.31], ... % GN
    [0.93, 0.69, 0.39], ... % PN
    [0.93, 0.84, 0.39], ... % Z
    [0.64, 0.45, 0.68], ... % PP
    [0.47, 0.67, 0.35]      % GP
};
labels = {'GN', 'PN', 'Z', 'PP', 'GP'};

figure;
%clf(figure(1));

subplot(3,1,1); hold on;
funcoes_erro = {error_GN_T, error_PN_T, error_zero_T, error_PP_T, error_GP_T};
for idx_f = 1:5
    plot(u_disc_erro_temp, funcoes_erro{idx_f}, 'Color', cores{idx_f}, 'LineWidth', 2);
    [max_val, idx_m] = max(funcoes_erro{idx_f});
    text(u_disc_erro_temp(idx_m), max_val + 0.05, labels{idx_f}, 'Color', cores{idx_f}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Input: Error', 'FontSize',16);
xlabel('Error');
ylabel('Membership Degree (\mu)');
axis([-30 30 0 1.2]); grid on; hold off;

subplot(3,1,2); hold on;
funcoes_var = {var_error_GN_T, var_error_PN_T, var_error_zero_T, var_error_PP_T, var_error_GP_T};
for idx_f = 1:5
    plot(u_disc_Derro_temp, funcoes_var{idx_f}, 'Color', cores{idx_f}, 'LineWidth', 2);
    [max_val, idx_m] = max(funcoes_var{idx_f});
    text(u_disc_Derro_temp(idx_m), max_val + 0.05, labels{idx_f}, 'Color', cores{idx_f}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Input: Error Variation', 'FontSize',16);
xlabel('Error Variation');
ylabel('Membership Degree (\mu)');
axis([-4 4 0 1.2]); grid on; hold off;

subplot(3,1,3); hold on;
x_coord = [vGNT, vPNT, vZT, vPPT, vGPT];
y_coord = ones(1, 5);
for idx_f = 1:length(x_coord)
    stem(x_coord(idx_f), y_coord(idx_f), 'LineWidth', 2, 'Color', cores{idx_f}, ...
        'MarkerFaceColor', cores{idx_f}, 'Marker', 'o', 'MarkerSize', 6);
    text(x_coord(idx_f), 1.1, labels{idx_f}, 'Color', cores{idx_f}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
set(gca, 'XTick', x_coord, 'XTickLabel', x_coord);
title('Output: Control Signal Variation', 'FontSize',16);
xlabel('Singleton Value');
ylabel('Membership Degree (\mu)');
axis([-3 3 0 1.25]); grid on; hold off;

%% SIMULAÇÃO
amostras = [300 600 900];
i = 3; % Seleção do modelo: 1, 2 ou 3

% Inicialização dos vetores
r_1t  = zeros(1, qde_amostras);
y_1t  = zeros(1, qde_amostras);
u_1t  = zeros(1, qde_amostras);
y_11t = zeros(1, qde_amostras);
erro1 = zeros(1, qde_amostras);
de1   = zeros(1, qde_amostras);
du1   = zeros(1, qde_amostras);

% Referências
r_1t(1:amostras(1)) = 30;
r_1t((amostras(1)+1):(amostras(2))) = 36;
r_1t((amostras(2)+1):amostras(3)) = 33;

tempo = 0:T_amostra:(qde_amostras-1)*T_amostra;
y_1t_inicial = 22;

% Condição inicial e ponteiro de amostragem
if i ~= 3
    n11 = num_mat{i,1}; d11 = den_mat{i,1};
    cont = am_Td11(i) + 2;
else
    cont = 6;
end

% Condições Iniciais
for k = 1:(cont-1)
    y_1t(k) = y_1t_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
end

%% LOOP DE CONTROLE FUZZY
for k = cont:qde_amostras
    % Equação de diferenças conforme variação paramétrica
    if i == 3
        y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    else
        y_11t(k) = -d11(2)*y_11t(k-1) + n11(1)*u_1t(k-am_Td11(i)) + n11(2)*u_1t(k-am_Td11(i)-1);
    end

    % Saída real com off-set inicial
    y_1t(k) = y_11t(k) + y_1t_inicial;

    % Erro e Variação do Erro
    erro1(k) = r_1t(k) - y_1t(k);
    e1_fuzzy = erro1(k) * Escala_eT;
    
    de1(k) = erro1(k) - erro1(k-1);
    de1_fuzzy = de1(k) * Escala_deT;

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
    out1 = r1 * vGNT; out2 = r2 * vPNT; out3 = r3 * vPNT; out4 = r4 * vGNT; out5 = r5 * vPPT;
    out6 = r6 * vGNT; out7 = r7 * vPNT; out8 = r8 * vPNT; out9 = r9 * vZT; out10 = r10 * vGPT;
    out11 = r11 * vPNT; out12 = r12 * vPNT; out13 = r13 * vZT; out14 = r14 * vGPT; out15 = r15 * vGNT;
    out16 = r16 * vGNT; out17 = r17 * vZT; out18 = r18 * vGPT; out19 = r19 * vGPT; out20 = r20 * vGPT;
    out21 = r21 * vPPT; out22 = r22 * vGPT; out23 = r23 * vGPT; out24 = r24 * vGPT; out25 = r25 * vGPT;

    % Defuzzificação (CoA-MédiaPonderada)
    sum_weight = (r1+r2+r3+r4+r5+r6+r7+r8+r9+r10+r11+r12+r13+r14+r15+r16+r17+r18+r19+r20+r21+r22+r23+r24+r25);
    if sum_weight > 0
        sum_out = (out1+out2+out3+out4+out5+out6+out7+out8+out9+out10+out11+out12+out13+out14+out15+out16+out17+out18+out19+out20+out21+out22+out23+out24+out25);
        du_out = sum_out / sum_weight;
    else
        du_out = 0;
    end

    % Acumulação da Ação de Controle com Saturação [0, 100]%
    du1(k) = Escala_duT * du_out;
    u_1t(k) = u_1t(k-1) + du1(k);

    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end



% %% ========================================================================
% % GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) - TEMPERATURA E UMIDADE
% %% ========================================================================
% % 1. Definir a resolução (aumentada para 40 para curvas mais suaves)
% res = 40; 
% e_range = linspace(-30, 30, res);
% de_range = linspace(-3, 3, res);
% [E, DE] = meshgrid(e_range, de_range);
% 
% Z_temp = zeros(res, res);
% Z_umid = zeros(res, res);
% 
% % 2. Loop para calcular a saída de ambas as variáveis
% for i = 1:res
%     for j = 1:res
%         curr_e = E(i,j);
%         curr_de = DE(i,j);
% 
%         % Ajusta entradas para os domínios das funções de pertinência
%         curr_e_T = max(min(curr_e, u_disc_erro_temp(end)), u_disc_erro_temp(1));
%         curr_de_T = max(min(curr_de, u_disc_Derro_temp(end)), u_disc_Derro_temp(1));
%         curr_e_U = max(min(curr_e, u_disc_erro_umid(end)), u_disc_erro_umid(1));
%         curr_de_U = max(min(curr_de, u_disc_Derro_umid(end)), u_disc_Derro_umid(1));
% 
%         % --- CÁLCULO PARA TEMPERATURA ---
%         st = [singleton(u_disc_erro_temp, error_GN_T, curr_e_T), ...
%               singleton(u_disc_erro_temp, error_PN_T, curr_e_T), ...
%               singleton(u_disc_erro_temp, error_zero_T, curr_e_T), ...
%               singleton(u_disc_erro_temp, error_PP_T, curr_e_T), ...
%               singleton(u_disc_erro_temp, error_GP_T, curr_e_T)];
% 
%         std = [singleton(u_disc_Derro_temp, var_error_GN_T, curr_de_T), ...
%                singleton(u_disc_Derro_temp, var_error_PN_T, curr_de_T), ...
%                singleton(u_disc_Derro_temp, var_error_zero_T, curr_de_T), ...
%                singleton(u_disc_Derro_temp, var_error_PP_T, curr_de_T), ...
%                singleton(u_disc_Derro_temp, var_error_GP_T, curr_de_T)];
% 
%         % Vetor vT: Segue exatamente a lógica out1 a out25 do seu loop
%         vT = [vGNT, vPNT, vPNT, vPNT, vPPT, ... % out1-5
%               vGNT, vPNT, vPNT, vZT,  vGPT, ... % out6-10
%               vPNT, vPNT, vZT,  vPPT, vGNT, ... % out11-15
%               vPNT, vZT,  vGPT, vGPT, vGPT, ... % out16-20
%               vPPT, vGPT, vGPT, vGPT, vGPT];    % out21-25
% 
%         rt = [];
%         for m = 1:5, for n = 1:5, rt = [rt, min(st(m), std(n))]; end; end % 
%         Z_temp(i,j) = sum(rt .* vT) / (sum(rt) + (sum(rt)==0));
% 
%         % --- CÁLCULO PARA UMIDADE ---
%         su = [singleton(u_disc_erro_umid, error_GN_U, curr_e_U), ...
%               singleton(u_disc_erro_umid, error_PN_U, curr_e_U), ...
%               singleton(u_disc_erro_umid, error_zero_U, curr_e_U), ...
%               singleton(u_disc_erro_umid, error_PP_U, curr_e_U), ...
%               singleton(u_disc_erro_umid, error_GP_U, curr_e_U)];
% 
%         sud = [singleton(u_disc_Derro_umid, var_error_GN_U, curr_de_U), ...
%                singleton(u_disc_Derro_umid, var_error_PN_U, curr_de_U), ...
%                singleton(u_disc_Derro_umid, var_error_zero_U, curr_de_U), ...
%                singleton(u_disc_Derro_umid, var_error_PP_U, curr_de_U), ...
%                singleton(u_disc_Derro_umid, var_error_GP_U, curr_de_U)];
% 
%         % Vetor vU: Segue exatamente a lógica out1_U a out25_U do seu loop
%         vU = [vGNU, vPNU, vPNU, vPNU, vPPU, ... % out1-5_U
%               vGNU, vPNU, vPNU, vZU,  vGPU, ... % out6-10_U
%               vPNU, vPNU, vZU,  vPPU, vGNU, ... % out11-15_U
%               vPNU, vZU,  vGPU, vGPU, vGPU, ... % out16-20_U
%               vZU,  vPPU, vGPU, vGPU, vGPU];    % out21-25_U
% 
%         ru = [];
%         for m = 1:5, for n = 1:5, ru = [ru, min(su(m), sud(n))]; end; end
%         Z_umid(i,j) = sum(ru .* vU) / (sum(ru) + (sum(ru)==0));
%     end
% end
% 
% % 3. Plotagem das superfícies
% figure('Name', 'Control Surfaces', 'Color', 'w');
% 
% % Temperatura
% subplot(1,2,1);
% surf(E, DE, Z_temp, 'EdgeColor', 'k', 'LineWidth', 0.1); 
% title('Control Surface: Temperatura (\Delta u_T)');
% xt = xlabel('Erro (e)'); 
% xt.Rotation = 30;
% ht = ylabel('\Delta Erro (\Delta e)');
% ht.Rotation = -30;          % inclina o texto
% ht.HorizontalAlignment = 'right';
% ht.VerticalAlignment = 'middle';
% ht.Position = [-50, -1.5, -2];   % aproxima do eixo, ajuste conforme necessário
% 
% zlabel('\Delta u');
% colormap('jet'); colorbar; grid on;
% view(-45, 30);
% caxis([vGNT vGPT]); % Ajusta escala para os limites da temperatura
% 
% % Umidade
% subplot(1,2,2);
% surf(E, DE, Z_umid, 'EdgeColor', 'k', 'LineWidth', 0.1);
% title('Superfície: Umidade (\Delta u_U)');
% xu = xlabel('Erro (e)'); 
% xu.Rotation = 30;
% 
% hu = ylabel('\Delta Erro (\Delta e)');
% hu.Rotation = -30;          % inclina o texto
% hu.HorizontalAlignment = 'right';
% hu.VerticalAlignment = 'middle';
% hu.Position = [-30, -3, -1];   % aproxima do eixo, ajuste conforme necessário
% zlabel('\Delta u');
% colormap('jet'); colorbar; grid on;
% view(-45, 30);
% caxis([vGNU vGPU]); % Ajusta escala para os limites da umidade
% 4. SALVAR DADOS (Mantendo sua estrutura Switch/Case)

end
    T = table(tempo(:), r_1t(:), y_1t(:), u_1t(:), erro1(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura','Saida_Temperatura', 'Controle_Temperatura', 'Erro_Temperatura'});
    switch i
        case 1
            filename = 'Tables/incubadora_var_param1Fuzzy_Temp.csv';
        case 2
            filename = 'Tables/incubadora_var_param2Fuzzy_Temp.csv';
        otherwise
            filename = 'Tables/incubadora_var_param100Fuzzy_Temp.csv';
    end
    if ~exist('Tables', 'dir'), mkdir('Tables'); end
    writetable(T, filename);
    disp(['Arquivo salvo: ' filename]);
%% PLOTAGEM DOS RESULTADOS DA SIMULAÇÃO
figure; 
%clf(figure(2));

subplot(2, 1, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_1t, 'b', 'LineWidth', 2);
title(['Saída de Temperatura Desacoplada (y_{11}) - Caso i = ' num2str(i)]);
xlabel('Tempo (min)'); ylabel('Temperatura (°C)');
legend('Referência', 'Saída'); grid on;

subplot(2, 1, 2);
plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
title('Sinal de Controle (u_1)');
xlabel('Tempo (min)'); ylabel('Sinal de Controle (%)'); grid on;
%==== SALVAR DADOS EM PLANILHA ====
%T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
 %   'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});

%filename = 'planilhas/dados_FLC_TITO_patamares_nao_norm.csv';
%writetable(T, filename);
%disp(['Dados salvos em: ' filename]);