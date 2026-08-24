clear;       % Limpa todas as variáveis da memória
% Lê os dados da planilha
% escolher TECNICA DE CONTROLE
prompt = 'Qual a tecnica de controle? (1 - ZN, 2 - Astrom, 3 - Fuzzy)\n';
opcao_controle = input(prompt);

while (opcao_controle ~= 1 && opcao_controle ~= 2 && opcao_controle ~= 3)
    disp('Opção inválida! Escolha 1, 2 ou 3.');
    opcao_controle = input(prompt);
end


% DEFINE OS CAMINHOS (Fora do while, agora que var é válida)
if opcao_controle == 1
     dados = readtable('tuning_sequencial_method_ZN/planilhas/dados_PID_ZN_incubadora.csv');
elseif opcao_controle == 2
     dados = readtable('tuning_sequencial_method_RELE/dados_PID_ASTROM_incubadora.csv');
else % var só pode ser 2 aqui
    dados = readtable('fuzzy_sem_toolbox/planilhas/dados_FLC_TITO_patamares_nao_norm.csv');
end

qde_amostras = height(dados);

% Extrai colunas
Tempo     = dados.Tempo;
r_1temp   = dados.Referencia_Temperatura;
r_2umid   = dados.Referencia_Umidade;
y_1temp   = dados.Saida_Temperatura;
y_2umid   = dados.Saida_Umidade;
u_1temp   = dados.Sinal_Controle_Temperatura;
u_2umid   = dados.Sinal_Controle_Umidade;
erro1temp = dados.Erro_Temperatura;
erro2umid = dados.Erro_Umidade;

% Definindo limites das faixas
lim_p1T = 1;
lim_p2T = floor(qde_amostras/3);

lim_p1U = 1;
lim_p2U = floor(2*qde_amostras/3);
a1 = 0.2;
a2 = 0.7 ;
a3 = 0.1;
%Indice de Goodhart
%tem por objetivo ser uma medida de eficácia do sistema
%GH = a1*e1 +a2*e2 + a3*e3
%e1: media do sinal de controle; 
% e2: variacia do sinal de controle em tornodo ponto médio; 
% e3: Indice IAE

% Função para métricas com a fórmula exata: (1/N) * sum
% Função para métricas corrigida e com parênteses balanceados
calc_metrics = @(y,u,e,t,variavel,patamar) struct( ...
    'Variavel', variavel, ...
    'Patamar', patamar, ...
    'Media_Saida', mean(y), ...
    'Media_Controle', mean(u), ...
    'Var_Saida', var(y,1), ...
    'Var_Controle', var(u,1), ...
    'IAE', sum(abs(e)), ...         
    'ITAE', sum(t .* abs(e)), ...
    'Goodhart', (a1 * mean(u)) + (a2 * var(u,1)) + (a3 * sum(abs(e))) );
     
%temperatura
% ---- P1 ----
p1_temp = calc_metrics(y_1temp(lim_p1T:lim_p2T), u_1temp(lim_p1T:lim_p2T), erro1temp(lim_p1T:lim_p2T), Tempo(lim_p1T:lim_p2T), 'Temperatura', '30°C');
p1_umid = calc_metrics(y_2umid(lim_p1U:lim_p2U), u_2umid(lim_p1U:lim_p2U), erro2umid(lim_p1U:lim_p2U), Tempo(lim_p1T:lim_p2U), 'Umidade', '55%');

% ---- P2 ----
p2_temp = calc_metrics(y_1temp(lim_p2T+1:qde_amostras), u_1temp(lim_p2T+1:qde_amostras), erro1temp(lim_p2T+1:qde_amostras), Tempo(lim_p2T+1:qde_amostras), 'Temperatura', '36°C');
p2_umid = calc_metrics(y_2umid(lim_p2U+1:qde_amostras), u_2umid(lim_p2U+1:qde_amostras), erro2umid(lim_p2U+1:qde_amostras),Tempo(lim_p2U+1:qde_amostras), 'Umidade', '65%');


% Junta todos os resultados em uma tabela
Resultados = struct2table([p1_temp, p1_umid, p2_temp, p2_umid]);
% Opcional: Salvar o relatório final
if opcao_controle == 1
    res = 'tuning_sequencial_method_ZN/planilhas/metricas_ZN.csv';
elseif opcao_controle == 3
    res = 'fuzzy_sem_toolbox/planilhas/metricas_FUZZY.csv';
end
writetable(Resultados, res);
disp(Resultados);

% Umidade