fis = mamfis('Name', 'Fuzzy_umidade');

% 2. Adiciona Variáveis de Entrada: Erro (e) e Variação do Erro (de)
% Range de [-1 1] mantém a lógica de normalização das entradas.
fis = addInput(fis, [-1 1], 'Name', 'e');
fis = addInput(fis, [-1 1], 'Name', 'de');

% 3. Define Funções de Pertinência para ENTRADAS
% Termos: NB, NS, Z, PS, PB (Permanecem inalterados)
% Para 'e'
% MFs de 'e' aprimoradas para cobertura total
fis = addMF(fis, 'e', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'e', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'e', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'e', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'e', 'trimf', [0.5 1 1], 'Name', 'PB');
figure(1);
subplot(3,1,1);
plotmf(fis, "input", 1);axis([-1 1 0 1])
title('Erro')
% Repetir MFs para 'de' (Variação do Erro)
% MFs de 'e' aprimoradas para cobertura total
fis = addMF(fis, 'de', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'de', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'de', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'de', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'de', 'trimf', [0.5 1 1], 'Name', 'PB');
subplot(3,1,2);
plotmf(fis, "input", 2);axis([-1 1 0 1])
title('Variacao do erro')

fis = addOutput(fis, [-1 1], 'Name', 'du'); %saida sinal de controle

fis = addMF(fis, 'du', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'du', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'du', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'du', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'du', 'trimf', [0.5 1 1], 'Name', 'PB');

subplot(3,1,3);
plotmf(fis, "output", 1);axis([-1 1 0 1])
title('Variacao do sinal de controle')
regras = [...
    % Erro (e) é NB (Saída > Referência - Overshoot)
    "if e is NB and de is NB then du is NB"; ...
    "if e is NB and de is NS then du is NB"; ...
    "if e is NB and de is Z then du is NS"; ...
    "if e is NB and de is PS then du is NS"; ...
    "if e is NB and de is PB then du is PS"; ...  <- Suaviza o retorno para evitar oscilação

    % Erro (e) é NS
    "if e is NS and de is NB then du is NB"; ...
    "if e is NS and de is NS then du is NS"; ...
    "if e is NS and de is Z then du is NS"; ...
    "if e is NS and de is PS then du is Z"; ...
    "if e is NS and de is PB then du is PB"; ...

    % Erro (e) é Z
    "if e is Z and de is NB then du is NS"; ...
    "if e is Z and de is NS then du is NS"; ...
    "if e is Z and de is Z then du is Z"; ...
    "if e is Z and de is PS then du is PS"; ...
    "if e is Z and de is PB then du is PB"; ...

    % Erro (e) é PS
    "if e is PS and de is NB then du is NS"; ...
    "if e is PS and de is NS then du is Z"; ...
    "if e is PS and de is Z then du is PS"; ...
    "if e is PS and de is PS then du is PB"; ...
    "if e is PS and de is PB then du is PB"; ...

    % Erro (e) é PB (Saída << Referência - Undershoot)
    "if e is PB and de is NB then du is PB"; ...  
    "if e is PB and de is NS then du is PB"; ...  
    "if e is PB and de is Z then du is PB"; ...
    "if e is PB and de is PS then du is PB"; ...
    "if e is PB and de is PB then du is PB"
];
fis = addRule(fis, regras); 
% Garante que a defuzzificação é o Centroid (padrão, mas bom verificar)
fis.defuzzMethod = 'centroid';
% Visualizacao da superficie de controle
figure(2);
plotfis(fis);
figure(3);

gensurf(fis, [1 2], 1); 
title('Superfície de Controle');
%escrever funcao
writefis(fis, 'Fuzzy_umidade.fis');


% xlabel('Erro (e)');
% ylabel('Variação do Erro (de)');
% zlabel('Variação do Sinal de Controle (du)');