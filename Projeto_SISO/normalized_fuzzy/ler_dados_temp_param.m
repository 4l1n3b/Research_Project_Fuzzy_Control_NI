% Lê os dados da planilha
% dados = readtable('planilhas/dados_PID_astrom_SISO_temperatura.csv');
dados = readtable('planilhas/dados_FLC_SISO_temperatura_patamares.csv');
Qde_amostras = height(dados);

% Extrai colunas
Tempo     = dados.Tempo;
r_1temp   = dados.Referencia_Temperatura;
y_1temp   = dados.Saida_Temperatura;
u_1temp   = dados.Sinal_Controle_Temperatura;
erro1temp = dados.Erro_Temperatura;

% Definindo limites das faixas
lim_p1 = 1;
lim_p2 = floor(Qde_amostras/3);
lim_p3 = floor(2*Qde_amostras/3);

% --- Função anônima para métricas ---
% A função agora recebe o vetor de tempo como um quarto argumento
calc_metrics = @(y,u,e,t,variavel,patamar) struct( ...
    'Variavel', variavel, ...
    'Patamar', patamar, ...
    'Media_Saida', mean(y), ...
    'Media_Controle', mean(u), ...
    'Var_Saida', var(y,1), ...
    'Var_Controle', var(u,1), ...
    'IAE', sum(abs(e)), ...
    'ITAE', sum(t .* abs(e)) ); 

% ---- P1 ----
% Passando os vetores de tempo, saída, controle e erro para a função
p1_temp = calc_metrics(y_1temp(lim_p1:lim_p2), u_1temp(lim_p1:lim_p2), erro1temp(lim_p1:lim_p2), Tempo(lim_p1:lim_p2), 'Temperatura', '30°C');

% ---- P2 ----
p2_temp = calc_metrics(y_1temp(lim_p2+1:lim_p3), u_1temp(lim_p2+1:lim_p3), erro1temp(lim_p2+1:lim_p3), Tempo(lim_p2+1:lim_p3), 'Temperatura', '36°C');

% ---- P3 ----
p3_temp = calc_metrics(y_1temp(lim_p3+1:Qde_amostras), u_1temp(lim_p3+1:Qde_amostras), erro1temp(lim_p3+1:Qde_amostras), Tempo(lim_p3+1:Qde_amostras), 'Temperatura', '36°C');

% Junta todos os resultados em uma tabela
Resultados = struct2table([p1_temp, p2_temp, p3_temp]);
disp(Resultados);