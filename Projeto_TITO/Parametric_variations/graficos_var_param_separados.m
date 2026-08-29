clear all; clc;
% =======================================
%% Definição dos caminhos dos arquivos (Organizados por Variação)
% Ordem: {Variação 1, Variação 2, Nominal(100)}
files_PID = {'Tables/ZN_var_paramTEST/incubadora_var_param1ZN.csv', ...
    'Tables/ZN_var_paramTEST/incubadora_var_param2ZN.csv', ...
    'Tables/ZN_var_paramTEST/incubadora_var_param100ZN.csv'};

files_Fuzzy = {'Tables/Fuzzy/incubadora_var_param1Fuzzy.csv', ...
    'Tables/Fuzzy/incubadora_var_param2Fuzzy.csv', ...
    'Tables/Fuzzy/incubadora_var_param100Fuzzy.csv'};

% =======================================
%% Vetores de legenda e titulo
% =======================================
titulos_eng = {'Parametric Variation 1', ...
    'Parametric Variation 2', ...
    'Original Model'};
titulos_pt = {'Variação Paramétrica 1', ...
    'Variação Paramétrica  2', ...
    'Modelo Original'};
legend_eng = {' - Temperature', ' - Humidity','Temperature (°C)', 'Time (min)', 'Reference', 'Relative Humidity (%RH)'};
legend_pt = {' - Temperatura', ' - Umidade','Temperatura (°C)', 'Tempo (min)', 'Referência', 'Umidade Relativa (%UR)'};
% =======================================
%% Escolha de idioma
% =======================================
prompt = 'Qual a idioma vc deseja as figuras? (1 - PT-BR, 2 - Eng)\n';
opcao_idioma = input(prompt);

while (opcao_idioma ~= 1 && opcao_idioma ~= 2 )
    disp('Opção inválida! Escolha 1 ou 2.');
    opcao_idioma = input(prompt);
end
if opcao_idioma == 1
    titulos = titulos_pt;
    legenda = legend_pt;
else
    titulos = titulos_eng;
    legenda = legend_eng;
end

% =======================================
%% Design
% =======================================
% Cores e Estilos
cor_PID   = [0, 0.4470, 0.7410]; % Azul
cor_Fuzzy = [0.8500, 0.3250, 0.0980]; % Laranja/Vermelho
% cor_PID   = [0, 0, 0]; % Azul
% cor_Fuzzy = [0, 0, 0]; % Laranja/Vermelho
estilo_Ref = 'k--';


% =======================================
%% Saída do Sitema
% =======================================

figure('Name', 'Variações Paramétricas', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
for i = 1:length(titulos)
    % Carregar dados
    data_PID   = readtable(files_PID{i});
    data_Fuzzy = readtable(files_Fuzzy{i});

    tempo_min = data_PID.Tempo / 60; % Assume-se que o tempo é igual para ambos

    % Criar nova figura para cada variação
    fonte  = 14;
    if i == 1
        % --- SUBPLOT 1: TEMPERATURA ---
        subplot(3, length(titulos)-1, 3); hold on;
        plot(tempo_min, data_PID.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');

        % --- SUBPLOT 2: UMIDADE ---
        subplot(3, length(titulos)-1, 4); hold on;
        plot(tempo_min, data_PID.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');
    elseif i == 2
        subplot(3, length(titulos)-1, 5); hold on;
        plot(tempo_min, data_PID.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');

        % --- SUBPLOT 2: UMIDADE ---
        subplot(3, length(titulos)-1, 6); hold on;
        plot(tempo_min, data_PID.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');
    else
        % figure;
        subplot(3, length(titulos)-1, 1); hold on;
        plot(tempo_min, data_PID.Referencia_Temperatura, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');

        % --- SUBPLOT 2: UMIDADE ---
        subplot(3, length(titulos)-1, 2); hold on;
        plot(tempo_min, data_PID.Referencia_Umidade, estilo_Ref, 'LineWidth', 1);
        plot(tempo_min, data_PID.Saida_Umidade, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Saida_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend(legenda{5}, 'PID', 'Fuzzy', 'Location', 'best');
    end
end
% =======================================
%% Sinal de Controle
% =======================================
figure('Name', 'Variações Paramétricas', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
for i = 1:length(titulos)
    % Carregar dados
    data_PID   = readtable(files_PID{i});
    data_Fuzzy = readtable(files_Fuzzy{i});

    tempo_min = data_PID.Tempo / 60; % Assume-se que o tempo é igual para ambos

    % Criar nova figura para cada variação

    if i == 1
        % --- SUBPLOT 1: TEMPERATURA ---
        subplot(3, length(titulos)-1, 3); hold on;
        plot(tempo_min, data_PID.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');

        % --- SUBPLOT 2: UMIDADE ---
        subplot(3, length(titulos)-1, 4); hold on;
        plot(tempo_min, data_PID.Controle_Umidade, 'Color', cor_PID, 'LineWidth',.5);
        plot(tempo_min, data_Fuzzy.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');
    elseif i == 2
        subplot(3, length(titulos)-1, 5); hold on;
        plot(tempo_min, data_PID.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');
        % --- SUBPLOT 2: UMIDADE ---
        subplot(3, length(titulos)-1, 6); hold on;
        plot(tempo_min, data_PID.Controle_Umidade, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');
    else
        %figure;
        subplot(3,length(titulos)-1,1); hold on;
        plot(tempo_min, data_PID.Controle_Temperatura, 'Color', cor_PID, 'LineWidth', .5);
        plot(tempo_min, data_Fuzzy.Controle_Temperatura, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{1}], 'FontSize', fonte);
        ylabel(legenda{3});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');

        % --- SUBPLOT 2: UMIDADE ---
        subplot(3,length(titulos)-1, 2); hold on;
        plot(tempo_min, data_PID.Controle_Umidade, 'Color', cor_PID, 'LineWidth',.5);
        plot(tempo_min, data_Fuzzy.Controle_Umidade, 'Color', cor_Fuzzy, 'LineWidth', 1.8);

        title([titulos{i} legenda{2}], 'FontSize', fonte);
        ylabel(legenda{6});
        xlabel(legenda{4});
        grid on;
        legend('PID', 'Fuzzy', 'Location', 'best');
    end
end