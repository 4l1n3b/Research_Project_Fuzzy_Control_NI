% Lê os dados da planilha
dados = readtable('planilhas/dados_FLC_SISO_umidade_patamares.csv');

Qde_amostras = height(dados);

% Extrai colunas
Tempo     = dados.Tempo;
r_2umid   = dados.Referencia_Umidade;
y_2umid   = dados.Saida_Umidade;
u_2umid   = dados.Sinal_Controle_Umidade;
erro2umid = dados.Erro_Umidade;

% Definindo limites das faixas
lim_p1 = 1;
lim_p2 = floor(Qde_amostras/3);
lim_p3 = floor(2*Qde_amostras/3);

% Função anônima para métricas
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
p1_umid = calc_metrics(y_2umid(lim_p1:lim_p2), u_2umid(lim_p1:lim_p2), erro2umid(lim_p1:lim_p2),Tempo(lim_p1:lim_p2), 'Umidade', '50%');

% ---- P2 ----
p2_umid = calc_metrics(y_2umid(lim_p2+1:lim_p3), u_2umid(lim_p2+1:lim_p3), erro2umid(lim_p2+1:lim_p3),Tempo(lim_p2+1:lim_p3), 'Umidade', '65%');

% ---- P3 ----
p3_umid = calc_metrics(y_2umid(lim_p3+1:Qde_amostras), u_2umid(lim_p3+1:Qde_amostras), erro2umid(lim_p3+1:Qde_amostras),Tempo(lim_p3+1:Qde_amostras), 'Umidade', '55%');

% Junta todos os resultados em uma tabela
Resultados = struct2table([p1_umid, p2_umid, p3_umid]);

disp(Resultados);
