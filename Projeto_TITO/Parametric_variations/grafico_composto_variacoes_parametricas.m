% Gerar gráfico composto com os resultados
clear all; clc;

%Painel de seleçao conforme o controlador
ctrl = input('Qual controlador? 1 - Sem ctrl; 2 - PID; 3 - Fuzzy\n');
switch ctrl
    case 2
        filenames = {'Tables/ZN_var_paramTEST/incubadora_var_param1ZN.csv', ...
             'Tables/ZN_var_paramTEST/incubadora_var_param2ZN.csv', ...
             'Tables/ZN_var_paramTEST/incubadora_var_param100ZN.csv'};
        % Statement(s)
    case 3
        filenames = {'Tables/Fuzzy/incubadora_var_param1Fuzzy.csv', ...
             'Tables/Fuzzy/incubadora_var_param2Fuzzy.csv', ...
             'Tables/Fuzzy/incubadora_var_param100Fuzzy.csv'};
    otherwise
        filenames = {'Tables/incubadora_var_param1.csv', ...
             'Tables/incubadora_var_param2.csv', ...
             'Tables/incubadora_var_param100.csv'};
end
fig = figure;
clf(fig);
% Definição das cores personalizadas [R, G, B]
vermelho     = [1, 0, 0];
azul_escuro  = [0, 0, 1];
verde_neon   = [0.2, 1, 0]; 
preto        = [0, 0, 0];


lista_cores = {verde_neon, azul_escuro, vermelho};
for i = 1:length(filenames)
    T = readtable(filenames{i});
    tempo_min = T.Tempo / 60;
    
    % Plot Temperatura
    subplot(2, 1, 1); hold on;
    if i == 1 
        plot(tempo_min, T.Referencia_Temperatura, 'black--', 'LineWidth', 1.5);
    end
    % AQUI: Aplicando a cor personalizada
    plot(tempo_min, T.Saida_Temperatura, 'LineWidth', .5, 'Color', lista_cores{i});
    
    % Plot Umidade
    subplot(2, 1, 2); hold on;
    if i == 1
        plot(tempo_min, T.Referencia_Umidade, 'black--', 'LineWidth', 1.5);
    end
    % AQUI: Aplicando a cor personalizada
    plot(tempo_min, T.Saida_Umidade, 'LineWidth', .5, 'Color', lista_cores{i});
end

% --- Formatação Fora do Loop (Melhor Performance) ---

label_variacoes = {'Referência', 'Variação 1', 'Variação 2', 'Nominal'};

% Ajustes Finais: Temperatura
subplot(2, 1, 1);
title('Saída de Temperatura'); xlabel('Tempo (min)'); ylabel('Temperatura (°C)');
grid on; legend(label_variacoes, 'Location', 'best');


% Ajustes Finais: Umidade
subplot(2, 1, 2);
title('Saída de Umidade'); xlabel('Tempo (min)'); ylabel('Umidade (%)');
grid on; legend(label_variacoes, 'Location', 'best');


% Salvar opcional
% exportgraphics(fig, 'gráficos/PNG/Analise_Robustez.png', 'Resolution', 300);