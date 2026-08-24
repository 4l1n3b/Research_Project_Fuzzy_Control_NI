

%==========================================================================
% CONTROLADOR FLC (Fuzzy Logic Controller) P/ TEMPERATURA
%==========================================================================
%Observacoes
% erro>0 Siginifica que a saida esta abaixo da referencia
%erro<0 significa que a saida está acima d balor de referencia
% variacao do erro > 0 siginifica a temperatura esta aumentando muito
% variacao do erro < 0 significa que a temperatura esta diminuido
clear; clc;

qtde_amostras = 600;
T_amost = 18;
Escala_eU = 1/20;
Escala_deU= 1/5;
Escala_duU = 8;
%% DEFININDO OS PATAMARES DE CADA ENTRADA
r_2u = zeros(1, qtde_amostras);
r_2u(1:qtde_amostras) = 50;
r_2u(qtde_amostras /3+1:2*qtde_amostras/3) = 60;
r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55;

%% INICIALIZAÇÕES
u_2u = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
e = zeros(1, qtde_amostras);
de = zeros(1, qtde_amostras);
du = zeros(1, qtde_amostras);

temp_inicial = 22;
umid_inicial = 50;
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;

% Universo de discurso (local para a função)
u_disc = linspace(-1, 1, 10000);
error_GN_U   = trapezoidal(u_disc, -2, -1, -.85, -0.7);
error_PN_U   = triangular(u_disc, -.9, -.7, 0);
error_zero_U  = triangular(u_disc, -.6, 0, .4);
error_PP_U   = triangular(u_disc, 0, .3, .9);
error_GP_U    = trapezoidal(u_disc, 0.5, .9, 1, 2);

var_error_GN_U   = trapezoidal(u_disc, -2, -1, -.7, -0.5);
var_error_PN_U   = triangular(u_disc, -1, -.4, 0);
var_error_zero_U  = triangular(u_disc, -.5, 0, .5);
var_error_PP_U   = triangular(u_disc, 0, .4, 1);
var_error_GP_U    = trapezoidal(u_disc, 0.5, .7, 1, 2);

% Singletons de saida
vGPU = 1; vPPU = .6; vZU = 0; vPNU = -.7; vGNU = -.9;% Definição das cores e labels (Reutilizando para padronização)
cores = {
    [0.85, 0.33, 0.31], ... % GN
    [0.93, 0.69, 0.39], ... % PN
    [0.93, 0.84, 0.39], ... % Z
    [0.64, 0.45, 0.68], ... % PP
    [0.47, 0.67, 0.35]      % GP
    };
labels = {'GN', 'PN', 'Z', 'PP', 'GP'};
clf(figure(2));
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



%% LOOP DE CONTROLE (Simulação)
for k=1:2
    y_22u(k) = 50;
    e(k)=r_2u(k) - y_22u(k);
    tempo(k) = k*T_amost;
    de(k) = 0;
end
%Fecha a malha
for k=3:qtde_amostras
    % malha fechada - Umidade
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);

    %Calculand Erro e variacao do erro
    e(k) = r_2u(k) - y_22u(k);
    de(k) = e(k) - e(k-1);
    e_fuzzy = e(k)*Escala_eU;
    de_fuzzy = de(k)*Escala_deU;

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

    % --- NOVA BASE DE REGRAS PARA FORÇAR O AZUL (SAÍDA MÍNIMA) ---
    
    % Se o Erro é Grande Negativo (s1), a saída DEVE ser Grande Negativa (vGNU)
    r1U = min(s1, s6);  out1_U = r1U * vGNU; % Antes era vGNU
    r2U = min(s1, s7);  out2_U = r2U * vGNU; % Antes era vPNU
    r3U = min(s1, s8);  out3_U = r3U * vGNU; % Antes era vPNU
    r4U = min(s1, s9);  out4_U = r4U * vGNU; % Antes era vPNU
    r5U = min(s1, s10); out5_U = r5U * vPNU; % Antes era vPPU (Amarelo) -> Agora PN (Azul claro)
    
    % Se o Erro é Pequeno Negativo (s2)
    r6U = min(s2, s6);  out6_U = r6U * vGNU;
    r7U = min(s2, s7);  out7_U = r7U * vPNU;
    r8U = min(s2, s8);  out8_U = r8U * vPNU;
    r9U = min(s2, s9);  out9_U = r9U * vZU;
    r10U = min(s2, s10); out10_U = r10U * vPPU;
    
    % ... mantenha as outras regras de s3, s4 e s5 conforme desejar

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
    %sinal de controle
    du(k) = du_outU * Escala_duU;
    u_2u(k) = u_2u(k-1) + du(k);

    % Saturação
    if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
end

%% ========================================================================
% GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) - AJUSTADA
%% ========================================================================
% 1. Definir a resolução (maior resolução = gráfico mais liso)
res = 50; 
e_range = linspace(-1, 1, res);
de_range = linspace(-1, 1, res);
[E, DE] = meshgrid(e_range, de_range);
Z_umid = zeros(res, res);

% 2. Loop para calcular a saída
% Nota: i e j seguem a estrutura do meshgrid (linhas e colunas)
for i = 1:res
    for j = 1:res
        curr_e = E(i,j);
        curr_de = DE(i,j);
        
        % Fuzzificação instantânea para a superfície
        % Usando as mesmas funções de pertinência definidas anteriormente
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
        
        % Vetor de Singletons de saída (Base de Regras)
        % Exemplo de base de regras mais agressiva nos extremos:
% --- VETOR vU ATUALIZADO (Reflete as novas regras para "azular" as bordas) ---
% Note que as primeiras 5 posições (Erro GN) agora são quase todas vGNU.
        vU = [vGNU, vGNU, vGNU, vGNU, vPNU, ... % Regras 1-5 (Erro GN) -> Força o Azul
              vGNU, vPNU, vPNU, vZU,  vPPU, ... % Regras 6-10 (Erro PN)
              vPNU, vPNU, vZU,  vPPU, vGNU, ... % Regras 11-15 (Erro Z)
              vPNU, vZU,  vGPU, vGPU, vGPU, ... % Regras 16-20 (Erro PP)
              vZU,  vPPU, vGPU, vGPU, vGPU];    % Regras 21-25 (Erro GP) 
          
        % Aplicação das regras (Produto Cartesiano das entradas)
        regra_ativa = [];
        for m = 1:5     % Erro
            for n = 1:5 % Var Erro
                regra_ativa = [regra_ativa, min(su(m), sud(n))];
            end
        end
        
        % Defuzzificação (Média Ponderada)
        soma_pesos = sum(regra_ativa);
        if soma_pesos > 0
            Z_umid(i,j) = sum(regra_ativa .* vU) / soma_pesos;
        else
            Z_umid(i,j) = 0;
        end
    end
end

% 3. Plotagem Formatada
clf(figure(3));
figure(3);
set(gcf, 'Color', 'w'); % Fundo branco

% Plot da superfície
surf(E, DE, Z_umid);
zlim([-1 1]);      % Fixa o eixo Z entre o mínimo e máximo teórico
caxis([-1 1]);     % Força a escala de cores a usar o azul total em -1 e vermelho em 1
% Ajustes Estéticos
shading interp;      % Suaviza a transição de cores
colormap(jet(256));  % Cores vibrantes
colorbar;            % Barra de intensidade
lighting gouraud;    % Adiciona iluminação suave
camlight right;      % Direção da luz

title('Superfície de Controle Fuzzy (\Delta u)', 'FontSize', 12);
xlabel('Erro (e)', 'FontWeight', 'bold');
ylabel('\Delta Erro (\Delta e)', 'FontWeight', 'bold');
zlabel('\Delta Controle (\Delta u)', 'FontWeight', 'bold');

% Ajusta o ângulo de visão para melhor interpretação
view(-45, 30); 
grid on;

% 3. Plotagem das superfícies (Transposta para alinhar com o meshgrid)
% 3. Plotagem das superfícies (Visual Saturado "Jet")
% figure('Name', 'Superfície de Controle');
clf(figure(3));

figure(3);
% Umidade
surf(E * (1/Escala_eU), DE * (1/Escala_deU), Z_umid * Escala_duU, 'EdgeColor', 'k', 'LineWidth', 0.1);
title(['Superfície Real: Umidade (\Delta u_U = ', num2str(Escala_duU), ')']);
xlabel('Erro (e) [%]'); 
ylabel('\Delta Erro (\Delta e) [%]'); 
zlabel('\Delta u Real');
colormap('jet'); colorbar; grid on;
view(-45, 30);

% ========================================================================
% 7. PLOTAGEM DAS FUNÇÕES DE PERTINÊNCIA (ESCALA REAL)
% ========================================================================

% --- FIGURA 2: UMIDADE ---
clf(figure);
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
clf(figure);

figure('Name', 'Superfícies de Controle em Escala Real', 'Color', 'w');


% --- SUPERFÍCIE: UMIDADE ---
% Aplicando os ganhos de escala da umidade nos eixos e na saída Z:
surf(E * (1/Escala_eU), DE * (1/Escala_deU), Z_umid * Escala_duU, 'EdgeColor', 'k', 'LineWidth', 0.1);
title(['Superfície Real: Umidade (\Delta u_U = ', num2str(Escala_duU), ')']);
xlabel('Erro (e) [%]'); 
ylabel('\Delta Erro (\Delta e) [%]'); 
zlabel('\Delta u Real');
colormap('jet'); colorbar; grid on;
view(-45, 30);

%% ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_2u(:), y_22u(:), u_2u(:), e(:), ...
%     'VariableNames', {'Tempo','Referencia_Umidade', 'Saida_Umidade', 'Sinal_Controle_Umidade', 'Erro_Umidade'});
% % degrau
% % filename = 'Planilhas/dados_FLC_SISO_umidade_degrau.csv';
% % 3patamares
% filename = 'Planilhas/dados_FLC_SISO_umidade_patamares.csv';
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);

%% PLOTAGEM DOS RESULTADOS
clf(figure(6));

figure(6);
subplot(2, 1, 1);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1); hold on;
plot(tempo/60, y_22u, 'b', 'LineWidth', 1.5);
title('Resposta do Sistema com PID Fuzzy Puro');
xlabel('Tempo (min)'); ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída'); grid on;

subplot(2, 1, 2);
plot(tempo/60, u_2u, 'g', 'LineWidth', 1.5);
title('Sinal de Controle (u)');
xlabel('Tempo (min)'); ylabel('Umidade Relativa (%)'); grid on;

clf(figure(7))
figure(7);
subplot(2, 1, 1);
plot(tempo/60, e,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(2, 1, 2);
plot(tempo/60, de,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;



