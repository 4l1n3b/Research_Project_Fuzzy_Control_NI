clear;       % Limpa todas as variáveis da memória
clc;         % Limpa a janela de comandos
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
     dados1 = readtable('planilhas/dados_PID_2ZN_SISO_temperatura.csv');
     dados2 = readtable('planilhas/dados_PID_2ZN_SISO_umidade.csv');
elseif opcao_controle == 2
     dados1 = readtable('planilhas/dados_PID_astrom_SISO_temperatura.csv');
     dados2 = readtable('planilhas/dados_PID_astrom_SISO_umidade.csv');
else % var só pode ser 2 aqui
    dados1 = readtable('fuzzy/fuzzy_sem_toolbox/Planilhas/dados_2FLC_SISO_temperatura_patamares.csv');
    dados2 = readtable('fuzzy/fuzzy_sem_toolbox/Planilhas/dados_FLC_SISO_umidade_patamares.csv');
end

qde_amostras = height(dados1);

% Extrai colunas
Tempo     = dados1.Tempo;
r_1temp   = dados1.Referencia_Temperatura;
r_2umid   = dados2.Referencia_Umidade;
y_1temp   = dados1.Saida_Temperatura;
y_2umid   = dados2.Saida_Umidade;
u_1temp   = dados1.Sinal_Controle_Temperatura;
u_2umid   = dados2.Sinal_Controle_Umidade;
erro1temp = dados1.Erro_Temperatura;
erro2umid = dados2.Erro_Umidade;

% Definindo limites das faixas
lim_p1 = 1;
lim_p2 = floor(qde_amostras/3);
lim_p3 = floor(2*qde_amostras/3);

% Função para métricas
calc_metrics = @(y,u,e,t,variavel,patamar) struct( ...
    'Variavel', variavel, ...
    'Patamar', patamar, ...
    'Media_Saida', mean(y), ...
    'Media_Controle', mean(u), ...
    'Var_Saida', var(y,1), ... % Agora o MATLAB entende que é a função!
    'Var_Controle', var(u,1), ...
    'IAE', sum(abs(e)), ...
    'ITAE', sum(t .* abs(e)) );
%temperatura
% ---- P1 ----
p1_temp = calc_metrics(y_1temp(lim_p1:lim_p2), u_1temp(lim_p1:lim_p2), erro1temp(lim_p1:lim_p2), Tempo(lim_p1:lim_p2), 'Temperatura', '30°C');
p1_umid = calc_metrics(y_2umid(lim_p1:lim_p2), u_2umid(lim_p1:lim_p2), erro2umid(lim_p1:lim_p2), Tempo(lim_p1:lim_p2), 'Umidade', '50%');

% ---- P2 ----
p2_temp = calc_metrics(y_1temp(lim_p2+1:lim_p3), u_1temp(lim_p2+1:lim_p3), erro1temp(lim_p2+1:lim_p3), Tempo(lim_p2+1:lim_p3), 'Temperatura', '36°C');
p2_umid = calc_metrics(y_2umid(lim_p2+1:lim_p3), u_2umid(lim_p2+1:lim_p3), erro2umid(lim_p2+1:lim_p3),Tempo(lim_p2+1:lim_p3), 'Umidade', '60%');

% ---- P3 ----
p3_temp = calc_metrics(y_1temp(lim_p3+1:qde_amostras), u_1temp(lim_p3+1:qde_amostras), erro1temp(lim_p3+1:qde_amostras), Tempo(lim_p3+1:qde_amostras), 'Temperatura', '33°C');
p3_umid = calc_metrics(y_2umid(lim_p3+1:qde_amostras), u_2umid(lim_p3+1:qde_amostras), erro2umid(lim_p3+1:qde_amostras),Tempo(lim_p3+1:qde_amostras), 'Umidade', '55%');
% Junta todos os resultados em uma tabela
Resultados = struct2table([p1_temp, p1_umid, p2_temp, p2_umid, p3_temp, p3_umid]);

disp(Resultados);
% Umidade