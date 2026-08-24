clear;       % Limpa todas as variáveis da memória
%clc;         % Limpa a janela de comandos

% Lê os dados da planilha - escolher TECNICA DE CONTROLE
prompt = 'Qual a tecnica de controle? (1 - ZN, 2 - Astrom, 3 - Fuzzy)\n';
opcao_controle = input(prompt);

while (opcao_controle ~= 1 && opcao_controle ~= 2 && opcao_controle ~= 3)
    disp('Opção inválida! Escolha 1, 2 ou 3.');
    opcao_controle = input(prompt);
end

% Configuração de caminhos e sufixos baseada na sua estrutura de pastas
if opcao_controle == 1
    pasta = 'Tables/ZN_var_paramTEST/';
    sufixo = 'ZN.csv';
elseif opcao_controle == 2
    pasta = 'Tables/Astrom_var_param/';
    sufixo = 'Astrom.csv';
else
    pasta = 'Tables/Fuzzy/';
    sufixo = 'Fuzzy.csv';
end

% Vetor com os cenários que você gerou (1, 2 e o nominal 100)
cenarios = [1, 2, 100];
Todos_Resultados = []; % Array de structs para acumular

% Pesos do Índice de Goodhart
a1 = 0.2;
a2 = 0.7;
a3 = 0.1;

% Função para métricas usando 'sum' conforme solicitado
calc_metrics = @(y,u,e,t,variavel,patamar,cen) struct( ...
    'Cenario', cen, ...
    'Variavel', {variavel}, ... 
    'Patamar', {patamar}, ...
    'Media_Saida', mean(y), ...
    'Media_Controle', mean(u), ...
    'Var_Saida', var(y,1), ...
    'Var_Controle', var(u,1), ...
    'IAE', sum(abs(e)), ...         
    'ITAE', sum(t .* abs(e)), ...
    'IG', (a1 * mean(u)) + (a2 * var(u,1)) + (a3 * sum(abs(e))) ); % Parêntese de fechamento corrigido

%% LOOP DE PROCESSAMENTO POR CENÁRIO
for i = 1:length(cenarios)
    c = cenarios(i);
    % Monta o nome do arquivo conforme o padrão
    nome_arquivo = sprintf('%sincubadora_var_param%d%s', pasta, c, sufixo);
    
    if exist(nome_arquivo, 'file')
        dados = readtable(nome_arquivo);
        qde_amostras = height(dados);
        
        % Extrai colunas 
        Tempo     = dados.Tempo;
        y_1temp   = dados.Saida_Temperatura;
        y_2umid   = dados.Saida_Umidade;
        u_1temp   = dados.Controle_Temperatura;
        u_2umid   = dados.Controle_Umidade;
        erro1temp = dados.Erro_Temperatura;
        erro2umid = dados.Erro_Umidade;
        
        % Definindo limites das faixas
        lim_p1 = 1; % Ignora o transiente das 4 primeiras amostras
        lim_p2 = floor(qde_amostras/3);
        lim_p3 = floor(2*qde_amostras/3);
        
        % --- Cálculo das métricas para o cenário atual ---
        
        % TEMPERATURA: P1, P2 e P3
        p1_t = calc_metrics(y_1temp(lim_p1:lim_p2), u_1temp(lim_p1:lim_p2), erro1temp(lim_p1:lim_p2), Tempo(lim_p1:lim_p2), 'Temperatura', 'P1 (30°C)', c);
        p2_t = calc_metrics(y_1temp(lim_p2+1:qde_amostras), u_1temp(lim_p2+1:qde_amostras), erro1temp(lim_p2+1:qde_amostras), Tempo(lim_p2+1:qde_amostras), 'Temperatura', 'P2 (36°C)', c);
        
        % UMIDADE: P1, P2 e P3
        p1_u = calc_metrics(y_2umid(lim_p1:lim_p3), u_2umid(lim_p1:lim_p3), erro2umid(lim_p1:lim_p3), Tempo(lim_p1:lim_p3), 'Umidade', 'P1 (55%)', c);
        p2_u = calc_metrics(y_2umid(lim_p3+1:qde_amostras), u_2umid(lim_p3+1:qde_amostras), erro2umid(lim_p3+1:qde_amostras), Tempo(lim_p3+1:qde_amostras), 'Umidade', 'P2 (65%)', c);
        
        % Acumula no array de structs
        Todos_Resultados = [Todos_Resultados, p1_t, p2_t, p1_u, p2_u];
    else
        fprintf('Aviso: Arquivo %s não encontrado.\n', nome_arquivo);
    end
end

% Converte o array de structs acumulado para tabela final
Resultados = struct2table(Todos_Resultados);

% Exibição organizada
disp('---------------------------------------------------------');
disp(['Resultados da Técnica: ', sufixo]);
disp('---------------------------------------------------------');
disp(Resultados);

% Salvar o relatório final de acordo com a técnica escolhida
if opcao_controle == 1
    caminho_salvar = 'Tables/report_metricsZN.csv';
elseif opcao_controle == 2
    caminho_salvar = 'Tables/report_metricsASTROM.csv';
elseif opcao_controle == 3
    caminho_salvar = 'Tables/report_metricsFUZZY.csv';
end

writetable(Resultados, caminho_salvar);
disp(['Relatório salvo com sucesso em: ', caminho_salvar]);