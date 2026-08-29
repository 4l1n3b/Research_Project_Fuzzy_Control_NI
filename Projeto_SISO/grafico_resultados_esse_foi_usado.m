clear all; clc;

% Definição dos caminhos dos arquivos (Organizados por Variação)
% Ordem: {Variação 1, Variação 2, Nominal(100)}
files_PID_temp = {'Tables/incubadora_var_param1PID_Temp.csv', ...
             'Tables/incubadora_var_param2PID_Temp.csv', ...
             'Tables/incubadora_var_param100PID_Temp.csv'};

files_Fuzzy_temp = {'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param1Fuzzy_Temp.csv', ...
               'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param2Fuzzy_Temp.csv', ...
               'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param100Fuzzy_Temp.csv'};
files_PID_umid = {'Tables/incubadora_var_param1PID_Umid.csv', ...
             'Tables/incubadora_var_param2PID_Umid.csv', ...
             'Tables/incubadora_var_param100PID_Umid.csv'};

files_Fuzzy_umid = {'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param1Fuzzy_Umid.csv', ...
               'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param2Fuzzy_Umid.csv', ...
               'non-normalized_fuzzy/fuzzy_sem_toolbox/Tables/incubadora_var_param100Fuzzy_Umid.csv'};
titulos = {'Parametric Variation 1', ...
           'Parametric Variation 2', ...
           ' '};

% Cores e Estilos
cor_PID   = [0, 0.4470, 0.7410]; % Azul
cor_Fuzzy = [0.8500, 0.3250, 0.0980]; % Laranja/Vermelho
% cor_PID   = [0, 0, 0]; % Azul
% cor_Fuzzy = [0, 0, 0]; % Laranja/Vermelho
estilo_Ref = 'k--';
figure('Name', 'Variações Paramétricas', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
for i = 1:length(titulos)
    % Carregar dados
    data_PID_temp   = readtable(files_PID_temp{i});
    data_Fuzzy_temp = readtable(files_Fuzzy_temp{i});
    data_PID_umid   = readtable(files_PID_umid{i});
    data_Fuzzy_umid = readtable(files_Fuzzy_umid{i});
    tempo_min = data_PID_temp.Tempo / 60; % Assume-se que o tempo é igual para ambos
    
    % Criar nova figura para cada variação
    
    if i == 1
    % --- SUBPLOT 1: TEMPERATURA ---
    subplot(2, length(titulos)-1, 1); hold on;
    plot(tempo_min, data_PID_temp.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_temp.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} ' - Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2, length(titulos)-1, 2); hold on;
    plot(tempo_min, data_PID_umid.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_umid.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_umid.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} ' - Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    elseif i == 2
            subplot(2, length(titulos)-1, 3); hold on;
    plot(tempo_min, data_PID_temp.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_temp.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
   title([titulos{i} ' - Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2, length(titulos)-1, 4); hold on;
    plot(tempo_min, data_PID_umid.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_umid.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_umid.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
   title([titulos{i} ' - Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    else
    figure;
            subplot(2, 1, 1); hold on;
    plot(tempo_min, data_PID_temp.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_temp.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
     title([titulos{i} 'Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2, 1, 2); hold on;
    plot(tempo_min, data_PID_umid.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
    plot(tempo_min, data_PID_umid.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_umid.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} 'Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('Reference', 'PID', 'Fuzzy', 'Location', 'best');
    end
end

figure('Name', 'Variações Paramétricas', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
for i = 1:length(titulos)
    % Carregar dados
    data_PID_temp   = readtable(files_PID_temp{i});
    data_Fuzzy_temp = readtable(files_Fuzzy_temp{i});
    data_PID_umid   = readtable(files_PID_umid{i});
    data_Fuzzy_umid = readtable(files_Fuzzy_umid{i});
    
    tempo_min = data_PID_temp.Tempo / 60; % Assume-se que o tempo é igual para ambos
    
    % Criar nova figura para cada variação
    
    if i == 1
    % --- SUBPLOT 1: TEMPERATURA ---
    subplot(2, length(titulos)-1, 1); hold on;
    plot(tempo_min, data_PID_temp.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
     title([titulos{i} ' - Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2, length(titulos)-1, 2); hold on;
    plot(tempo_min, data_PID_umid.Controle_Umidade, 'Color', cor_PID, 'LineWidth',.5);
    plot(tempo_min, data_Fuzzy_umid.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} ' - Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    elseif i == 2
            subplot(2, length(titulos)-1, 3); hold on;
    plot(tempo_min, data_PID_temp.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
     title([titulos{i} ' - Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2, length(titulos)-1, 4); hold on;
    plot(tempo_min, data_PID_umid.Controle_Umidade, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_umid.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} ' - Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    else
       figure;
            subplot(2,1,1); hold on;
    plot(tempo_min, data_PID_temp.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
    plot(tempo_min, data_Fuzzy_temp.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
     title([titulos{i} 'Temperature'], 'FontSize',14);
    ylabel('Temperature (°C)');
    xlabel('Time (min)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    
    % --- SUBPLOT 2: UMIDADE ---
     subplot(2,1, 2); hold on;
    plot(tempo_min, data_PID_umid.Controle_Umidade, 'Color', cor_PID, 'LineWidth',.5);
    plot(tempo_min, data_Fuzzy_umid.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);
    
    title([titulos{i} 'Humidity'], 'FontSize',14);
    xlabel('Time (min)');
    ylabel('Relative Humidity (% RH)');
    grid on;
    legend('PID', 'Fuzzy', 'Location', 'best');
    end
end