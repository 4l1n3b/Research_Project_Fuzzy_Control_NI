

%==========================================================================
% CONTROLADOR FLC (Fuzzy Logic Controller) P/ TEMPERATURA
%==========================================================================
%Observaces
% erro>0 Siginifica que a saida esta abaixo da referencia
%erro<0 significa que a saida está acima d balor de referencia
% variacao do erro > 0 siginifica a temperatura esta aumentando muito
% variacao do erro < 0 significa que a temperatura esta diminuido
clear; clc; 
qtde_amostras = 600;
T_amost = 18;

%% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t = zeros(1, qtde_amostras); 
r_1t(1:qtde_amostras) = 30;
r_1t(round(qtde_amostras/3)+1:round(2*qtde_amostras/3)) = 36;
r_1t(round(2*qtde_amostras/3)+1:qtde_amostras) = 33;

%% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras); 
y_11t = zeros(1, qtde_amostras);
e = zeros(1, qtde_amostras);
de = zeros(1, qtde_amostras);
du = zeros(1, qtde_amostras);

temp_inicial = 22;
umid_inicial = 50;
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;

% Fatores de Escala das variaveis
Escala_eT= 1/22;
Escala_deT = 1/2; 
Escala_duT = 8;


 u_disc = linspace(-1, 1, 10000);

    error_GN_T   = trapezoidal(u_disc, -2, -1, -.85, -0.7);
    error_PN_T   = triangular(u_disc, -1, -.6, 0);
    error_zero_T  = triangular(u_disc, -.7, 0, .5);
    error_PP_T   = triangular(u_disc, 0, .4, 1);
    error_GP_T    = trapezoidal(u_disc, 0.6, .7, 1, 2);
    
    var_error_GN_T   = trapezoidal(u_disc, -2, -1, -.9, -0.5);
    var_error_PN_T   = triangular(u_disc, -1, -.5, 0);
    var_error_zero_T  = triangular(u_disc, -.5, 0, .5);
    var_error_PP_T   = triangular(u_disc, 0, .5, 1);
    var_error_GP_T    = trapezoidal(u_disc, 0.5, .9, 1, 2);

    % Singletons de saida
    vGPT   = .75; vPPT = .3; vZT = 0; vPNT = -.25; vGNT = -.4;

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
clf(figure(1))
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

for k = 1:5
    y_11t(k) = temp_inicial;
    e(k) = r_1t(k) - y_11t(k);
    de(k) = 0;
end

%% LOOP de Contrle
for k = 6:qtde_amostras
    % malha fechada - Temperatura
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
   
    %Calculand Erro e variacao do erro
    e(k) = r_1t(k) - y_11t(k); 
    de(k) = e(k) - e(k-1); 
    
    e_fuzzy = e(k)*Escala_eT;
    de_fuzzy = de(k)*Escala_deT;

  
    % Fuzzificação
    s1 = singleton(u_disc, error_GN_T, e_fuzzy);
    s2 = singleton(u_disc, error_PN_T, e_fuzzy);
    s3 = singleton(u_disc, error_zero_T, e_fuzzy);
    s4 = singleton(u_disc, error_PP_T, e_fuzzy);
    s5 = singleton(u_disc, error_GP_T, e_fuzzy);
    
    s6 = singleton(u_disc, var_error_GN_T, de_fuzzy);
    s7 = singleton(u_disc, var_error_PN_T, de_fuzzy);
    s8 = singleton(u_disc, var_error_zero_T, de_fuzzy);
    s9 = singleton(u_disc, var_error_PP_T, de_fuzzy); 
    s10 = singleton(u_disc, var_error_GP_T, de_fuzzy); 
    
    r1 = min(s1, s6); r2 = min(s1, s7); r3 = min(s1, s8); r4 = min(s1, s9); r5 = min(s1, s10);
    r6 = min(s2, s6); r7 = min(s2, s7); r8 = min(s2, s8); r9 = min(s2, s9); r10 = min(s2, s10);
    r11 = min(s3, s6); r12 = min(s3, s7); r13 = min(s3, s8); r14 = min(s3, s9); r15 = min(s3, s10);
    r16 = min(s4, s6); r17 = min(s4, s7); r18 = min(s4, s8); r19 = min(s4, s9); r20 = min(s4, s10);
    r21 = min(s5, s6); r22 = min(s5, s7); r23 = min(s5, s8); r24 = min(s5, s9); r25 = min(s5, s10);
    
    % Implicação
    out1 = r1 * vGNT; out2 = r2 * vPNT; out3 = r3 * vPNT; out4 = r4 * vPNT; out5 = r5 * vPPT;
    out6 = r6 * vGNT; out7 = r7 * vPNT; out8 = r8 * vPNT; out9 = r9 * vZT; out10 = r10 * vGPT;
    out11 = r11 * vPNT; out12 = r12 * vPNT; out13 = r13 * vZT; out14 = r14 * vPPT; out15 = r15 * vGNT;
    out16 = r16 * vPNT; out17 = r17 * vZT; out18 = r18 * vPPT; out19 = r19 * vGPT; out20 = r20 * vGPT;
    out21 = r21 * vGPT; out22 = r22 * vGPT; out23 = r23 * vGPT; out24 = r24 * vGPT; out25 = r25 * vGPT;

    % Agregação e Média Ponderada
    sum_weight = (r1+r2+r3+r4+r5+r6+r7+r8+r9+r10+r11+r12+r13+r14+r15+r16+r17+r18+r19+r20+r21+r22+r23+r24+r25);
    if sum_weight > 0
        sum_out = (out1+out2+out3+out4+out5+out6+out7+out8+out9+out10+out11+out12+out13+out14+out15+out16+out17+out18+out19+out20+out21+out22+out23+out24+out25);
        du_out = sum_out/ sum_weight;
    else
        du_out = 0;
    end
    %sinal de controle
    du(k) = du_out*Escala_duT;
    u_1t(k) = u_1t(k-1) + du(k);
    
    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
end
% % % % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), y_11t(:), u_1t(:), e(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Saida_Temperatura', 'Sinal_Controle_Temperatura', 'Erro_Temperatura'});
% % degrau
% % filename = 'Planilhas/dados_FLC_SISO_temperatura_degrau.csv';
% % 3patamares
% filename = 'Planilhas/dados_2FLC_SISO_temperatura_patamares.csv';
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);
% 
%% ========================================================================
% GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) - AJUSTADA
%% ========================================================================
% 1. Definir a resolução (maior resolução = gráfico mais liso)
res = 50; 
e_range = linspace(-1, 1, res);
de_range = linspace(-1, 1, res);
[E, DE] = meshgrid(e_range, de_range);
Z_temp = zeros(res, res);

% 2. Loop para calcular a saída
% Nota: i e j seguem a estrutura do meshgrid (linhas e colunas)
for i = 1:res
    for j = 1:res
        curr_e = E(i,j);
        curr_de = DE(i,j);
        
        % Fuzzificação instantânea para a superfície
        % Usando as mesmas funções de pertinência definidas anteriormente
        su = [singleton(u_disc, error_GN_T, curr_e), ...
              singleton(u_disc, error_PN_T, curr_e), ...
              singleton(u_disc, error_zero_T, curr_e), ...
              singleton(u_disc, error_PP_T, curr_e), ...
              singleton(u_disc, error_GP_T, curr_e)];
          
        sud = [singleton(u_disc, var_error_GN_T, curr_de), ...
               singleton(u_disc, var_error_PN_T, curr_de), ...
               singleton(u_disc, var_error_zero_T, curr_de), ...
               singleton(u_disc, var_error_PP_T, curr_de), ...
               singleton(u_disc, var_error_GP_T, curr_de)];
        
        % Vetor de Singletons de saída (Base de Regras)
        % Exemplo de base de regras mais agressiva nos extremos:
% --- VETOR vU ATUALIZADO (Reflete as novas regras para "azular" as bordas) ---
% Note que as primeiras 5 posições (Erro GN) agora são quase todas vGNU.
        vU = [vGNT, vPNT, vPNT, vPNT, vPPT, ... % Regras 1-5 (Erro GN) -> Força o Azul
              vGNT, vPNT, vPNT, vZT,  vGPT, ... % Regras 6-10 (Erro PN)
              vPNT, vPNT, vZT,  vPPT, vGNT, ... % Regras 11-15 (Erro Z)
              vPNT, vZT,  vPPT, vGPT, vGPT, ... % Regras 16-20 (Erro PP)
              vZT,  vGPT, vGPT, vGPT, vGPT];    % Regras 21-25 (Erro GP) 
         
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
            Z_temp(i,j) = sum(regra_ativa .* vU) / soma_pesos;
        else
            Z_temp(i,j) = 0;
        end
    end
end

% 3. Plotagem Formatada
clf(figure(3));
figure(3);
set(gcf, 'Color', 'w'); % Fundo branco

% Plot da superfície
surf(E, DE, Z_temp);
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
surf(E, DE, Z_temp', 'EdgeColor', 'k', 'LineWidth', 0.2);
title('Superfície de Controle: Temperatura');
xlabel('e'); ylabel('\Delta e'); zlabel('\Delta u');
colormap('jet');    % <--- Define o padrão de cores saturadas
colorbar;
grid on;
shading faceted;    % <--- Garante que a malha (grid) fique visível sobre as cores

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
axis([-22 22 0 1])
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


% ========================================================================
% GERAÇÃO DA SUPERFÍCIE DE CONTROLE (FLC) EM ESCALA REAL
% ========================================================================

figure('Name', 'Superfícies de Controle em Escala Real', 'Color', 'w');

% E e DE são as malhas normatizadas. Multiplicamos pelos inversos das escalas:
surf(E * (1/Escala_eT), DE * (1/Escala_deT), Z_temp * Escala_duT, 'EdgeColor', 'k', 'LineWidth', 0.1); 
title(['Superfície Real: Temperatura (\Delta u_T = ', num2str(Escala_duT), ')']);
xlabel('Erro (e) [°C]'); 
ylabel('\Delta Erro (\Delta e) [°C]'); 
zlabel('\Delta u Real');
colormap('jet'); colorbar; grid on;
view(-45, 30);


% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
clf(figure(4))

figure(4);
subplot(2, 1, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_11t, 'b', 'LineWidth', 2);
title('Resposta do Sistema com PID Fuzzy Puro');
xlabel('Tempo (min)'); ylabel('Temperatura (°C)');
legend('Referência', 'Saída'); grid on;

subplot(2, 1, 2);
plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)'); ylabel('Temperatura (°C)'); grid on;

