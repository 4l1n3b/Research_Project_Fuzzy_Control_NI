%==========================================================================
% CONTROLADOR FUZZY P/ MODELO DE INCUBADORA - APENAS UMIDADE (CANAL 22)
%==========================================================================
clear; clc; %close all;

ganho = 0.1;
qde_amostras = 900;
T_amostra = 18;

% Ganho estático (Temperatura desacoplada)
k22v = [20.923; 21.339];

% Constante de tempo
tau22v = [170.196; 177.685];

% Atraso de transporte (s) e em amostras
Td22v = [16; 15];
am_Td22 = [1, 1];

% Escalas do Controlador
Escala_eU = 1;
Escala_deU = 1;
Escala_duU = 1;

% Pré-alocação
num_mat = cell(2, 1);
den_mat = cell(2, 1);

% Discretização da Função de Transferência G22
for i = 1:2
    Gs_22 = tf([k22v(i)], [tau22v(i) 1], 'InputDelay', Td22v(i));
    Gz_22 = c2d(Gs_22, T_amostra, 'zoh');
    [num_mat{i}, den_mat{i}] = tfdata(Gz_22, 'v');
end

%% FUNÇÕES DE PERTINÊNCIA - UMIDADE
u_disc_erro_umid = linspace(-25, 25, 10000);
error_GN_U   = trapezoidal(u_disc_erro_umid, -26, -25, -15, -12.5);
error_PN_U   = triangular(u_disc_erro_umid, -22.8, -12, 0);
error_zero_U = triangular(u_disc_erro_umid, -11, 0, 11);
error_PP_U   = triangular(u_disc_erro_umid, 0, 8, 22.8);
error_GP_U   = trapezoidal(u_disc_erro_umid, 11, 16, 25, 26);

u_disc_Derro_umid = linspace(-7, 7, 10000);
var_error_GN_U   = trapezoidal(u_disc_Derro_umid, -8, -7, -6, -3.5);
var_error_PN_U   = triangular(u_disc_Derro_umid, -7, -2.5, 0);
var_error_zero_U = triangular(u_disc_Derro_umid, -2, 0, 2);
var_error_PP_U   = triangular(u_disc_Derro_umid, 0, 1, 7);
var_error_GP_U   = trapezoidal(u_disc_Derro_umid, 3.5, 4, 7, 8);

% Singletons de Saída
vGPU = .45; vPPU = 0.35; vZU = 0; vPNU = -.7; vGNU = -1.2;

% Definição das cores e labels (Reutilizando para padronização)
cores = {
    [0.85, 0.33, 0.31], ... % GN
    [0.93, 0.69, 0.39], ... % PN
    [0.93, 0.84, 0.39], ... % Z
    [0.64, 0.45, 0.68], ... % PP
    [0.47, 0.67, 0.35]      % GP
};
labels = {'GN', 'PN', 'Z', 'PP', 'GP'};
figure;
%clf(figure(2));
% --- Subplot 1: Erro (_U) ---
subplot(3,1,1)
hold on;
funcoes_erro_U = {error_GN_U, error_PN_U, error_zero_U, error_PP_U, error_GP_U};
for i = 1:5
    plot(u_disc_erro_umid, funcoes_erro_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    % Posicionamento automático da label no topo de cada função
    [max_val, idx] = max(funcoes_erro_U{i});
    text(u_disc_erro_umid(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Input: Error', 'FontSize',16);
xlabel('Error');
ylabel('Membership Degree (\mu)');
axis([-40 40 0 1.2]); grid on; hold off;
% --- Subplot 2: Variação do Erro (_U) ---
subplot(3,1,2)
hold on;
funcoes_var_U = {var_error_GN_U, var_error_PN_U, var_error_zero_U, var_error_PP_U, var_error_GP_U};
for i = 1:5
    plot(u_disc_Derro_umid, funcoes_var_U{i}, 'Color', cores{i}, 'LineWidth', 3);
    [max_val, idx] = max(funcoes_var_U{i});
    text(u_disc_Derro_umid(idx), max_val + 0.05, labels{i}, 'Color', cores{i}, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
end
title('Input: Error Variation', 'FontSize',16);
xlabel('Error Variation');
ylabel('Membership Degree (\mu)');
axis([-10 10 0 1.2]); grid on; hold off;
% --- Subplot 3: Saída (Singletons _U) ---
subplot(3,1,3)
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
title('Output: Control Signal Variation', 'FontSize',16);
xlabel('Singleton Value');
ylabel('Membership Degree (\mu)');
axis([-1.25 1.25 0 1.25]); grid on; hold off;


%% LOOP DE SIMULAÇÃO
amostras = [300 600 900];
i = 2; % Caso paramétrico selecionado

r_2u  = zeros(1, qde_amostras);
y_2u  = zeros(1, qde_amostras);
u_2u  = zeros(1, qde_amostras);
y_22u = zeros(1, qde_amostras);
erro2 = zeros(1, qde_amostras);
de2   = zeros(1, qde_amostras);
du2   = zeros(1, qde_amostras);

% Perfil de Referência
r_2u(1:amostras(1)) = 55;
r_2u((amostras(1)+1):amostras(2)) = 60;
r_2u((amostras(2)+1):amostras(3)) = 50;

tempo = (0:qde_amostras-1) * T_amostra;
y_2u_inicial = 50;

if i ~= 3
    n22 = num_mat{i}; 
    d22 = den_mat{i};
    cont = am_Td22(i) + 2;
else
    cont = 3;
end

% Condições Iniciais
for k = 1:cont-1
    y_2u(k) = y_2u_inicial;
    erro2(k) = r_2u(k) - y_2u(k);
    de2(k) = 0;
end

%% LOOP DE CONTROLE
for k = cont:qde_amostras
    % Modelo da Planta (Umidade)
    if i == 3
        y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);
    else
         y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*u_2u(k-am_Td22(i)) + n22(2)*u_2u(k-am_Td22(i)-1);
    end
    
    y_2u(k) = y_22u(k) + y_2u_inicial;
    
    % Erro e Variação
    erro2(k) = r_2u(k) - y_2u(k);
    de2(k)   = erro2(k) - erro2(k-1);
    
    e2_fuzzy  = erro2(k) * Escala_eU;
    de2_fuzzy = de2(k) * Escala_deU;
    
    % Fuzzificação
    s1 = singleton(u_disc_erro_umid, error_GN_U, e2_fuzzy);
    s2 = singleton(u_disc_erro_umid, error_PN_U, e2_fuzzy);
    s3 = singleton(u_disc_erro_umid, error_zero_U, e2_fuzzy);
    s4 = singleton(u_disc_erro_umid, error_PP_U, e2_fuzzy);
    s5 = singleton(u_disc_erro_umid, error_GP_U, e2_fuzzy);
    
    s6  = singleton(u_disc_Derro_umid, var_error_GN_U, de2_fuzzy);
    s7  = singleton(u_disc_Derro_umid, var_error_PN_U, de2_fuzzy);
    s8  = singleton(u_disc_Derro_umid, var_error_zero_U, de2_fuzzy);
    s9  = singleton(u_disc_Derro_umid, var_error_PP_U, de2_fuzzy);
    s10 = singleton(u_disc_Derro_umid, var_error_GP_U, de2_fuzzy);
    
    % Regras e Implicação
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
    r15U = min(s3, s10); out15_U = r15U * vGPU;
    
    r16U = min(s4, s6);  out16_U = r16U * vPPU;
    r17U = min(s4, s7);  out17_U = r17U * vPPU;
    r18U = min(s4, s8);  out18_U = r18U * vGPU;
    r19U = min(s4, s9);  out19_U = r19U * vGPU;
    r20U = min(s4, s10); out20_U = r20U * vGPU;
    
    r21U = min(s5, s6);  out21_U = r21U * vZU;
    r22U = min(s5, s7);  out22_U = r22U * vPPU;
    r23U = min(s5, s8);  out23_U = r23U * vGPU;
    r24U = min(s5, s9);  out24_U = r24U * vGPU;
    r25U = min(s5, s10); out25_U = r25U * vGPU;
    
    % Defuzzificação (Média Ponderada)
    sum_weightU = r1U+r2U+r3U+r4U+r5U+r6U+r7U+r8U+r9U+r10U+r11U+r12U+r13U+...
                  r14U+r15U+r16U+r17U+r18U+r19U+r20U+r21U+r22U+r23U+r24U+r25U;
              
    if sum_weightU > 0
        sum_outU = out1_U+out2_U+out3_U+out4_U+out5_U+out6_U+out7_U+out8_U+...
                   out9_U+out10_U+out11_U+out12_U+out13_U+out14_U+out15_U+...
                   out16_U+out17_U+out18_U+out19_U+out20_U+out21_U+out22_U+...
                   out23_U+out24_U+out25_U;
        du_outU = sum_outU / sum_weightU;
    else
        du_outU = 0;
    end
    
    % Atualização da Ação de Controle
    du2(k) = Escala_duU * du_outU;
    u_2u(k) = u_2u(k-1) + du2(k);
    
    % Saturação do Atuador
    u_2u(k) = min(max(u_2u(k), 0), 100);
end

%% PLOTAGEM DOS RESULTADOS
figure; 
%clf(figure(2));
subplot(2, 1, 1);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_2u, 'b', 'LineWidth', 2);
title('Saída de Umidade'); xlabel('Tempo (min)'); ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída'); grid on;

subplot(2, 1, 2);
plot(tempo/60, u_2u, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)'); xlabel('Tempo (min)'); ylabel('Sinal de Controle (%)');
grid on;




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
    T = table(tempo(:), r_2u(:), y_2u(:), u_2u(:), erro2(:), ...
        'VariableNames', {'Tempo', 'Referencia_Umidade','Saida_Umidade', 'Controle_Umidade', 'Erro_Umidade'});
    switch i
        case 1
            filename = 'Tables/incubadora_var_param1Fuzzy_Umid.csv';
        case 2
            filename = 'Tables/incubadora_var_param2Fuzzy_Umid.csv';
        otherwise
            filename = 'Tables/incubadora_var_param100Fuzzy_Umid.csv';
    end
    if ~exist('Tables', 'dir'), mkdir('Tables'); end
    writetable(T, filename);
    disp(['Arquivo salvo: ' filename]);
% % end
%==== SALVAR DADOS EM PLANILHA ====
%T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
 %   'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});

%filename = 'planilhas/dados_FLC_TITO_patamares_nao_norm.csv';
%writetable(T, filename);
%disp(['Dados salvos em: ' filename]);



