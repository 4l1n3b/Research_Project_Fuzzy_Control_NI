% Gerar gráfico composto com os resultados
clear; clc;
fig = figure(1);
clf(fig);

% Lista de arquivos para facilitar a manutenção
filenames = {'Tables/incubadora_var_param1.csv', ...
             'Tables/incubadora_var_param2.csv', ...
             'Tables/incubadora_var_param100.csv', ...
             'Tables/incubadora_var_param3.csv', ...
             'Tables/incubadora_var_param4.csv'};

for i = 1:length(filenames)
    T = readtable(filenames{i});
    
    tempo_min = T.Tempo / 60;
    
    % Plot Temperatura
    subplot(1, 2, 1); hold on;
    if i == 1 % Plota a referência apenas uma vez
        plot(tempo_min, T.Referencia_Temperatura, 'k--', 'LineWidth', 1.5);
    end
    plot(tempo_min, T.Saida_Temperatura, 'LineWidth', 2);
    
    % Plot Umidade
    subplot(1, 2, 2); hold on;
    if i == 1
        plot(tempo_min, T.Referencia_Umidade, 'k--', 'LineWidth', 1.5);
    end
    plot(tempo_min, T.Saida_Umidade, 'LineWidth', 2);
  
end

% --- Formatação Fora do Loop (Melhor Performance) ---

label_variacoes = {'Referência', 'Variação 1', 'Variação 2', 'Nominal', 'Variação 3', 'Variação 4'};

% Ajustes Finais: Temperatura
subplot(1, 2, 1);
title('Saída de Temperatura'); xlabel('Tempo (min)'); ylabel('Temperatura (°C)');
grid on; legend(label_variacoes, 'Location', 'best');


% Ajustes Finais: Umidade
subplot(1, 2, 2);
title('Saída de Umidade'); xlabel('Tempo (min)'); ylabel('Umidade (%)');
grid on; legend(label_variacoes, 'Location', 'best');


% Salvar opcional
% exportgraphics(fig, 'gráficos/PNG/Analise_Robustez.png', 'Resolution', 300);