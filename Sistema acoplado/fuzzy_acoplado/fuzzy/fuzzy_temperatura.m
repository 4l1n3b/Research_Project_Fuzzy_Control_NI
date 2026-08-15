fis = mamfis('Name', 'fuzzy_IN1_temperatura');

%Variáveis de Entrada: Erro (e) e Variação do Erro (de)
% Range de [-1 1] devido a normalização das entradas.
fis = addInput(fis, [-1 1], 'Name', 'e');
fis = addInput(fis, [-1 1], 'Name', 'de');

%Funções de Pertinência para ENTRADAS
% Termos: NB, NS, Z, PS, PB
%Erro
fis = addMF(fis, 'e', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'e', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'e', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'e', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'e', 'trimf', [0.5 1 1], 'Name', 'PB');
figure(1);
subplot(3,1,1);
plotmf(fis, "input", 1);axis([-1 1 0 1])
title('Erro')

% Variação do Erro
fis = addMF(fis, 'de', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'de', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'de', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'de', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'de', 'trimf', [0.5 1 1], 'Name', 'PB');
subplot(3,1,2);
plotmf(fis, "input", 2);axis([-1 1 0 1])
title('Variação do erro')

%Sinal de controle
fis = addOutput(fis, [-1 1], 'Name', 'du');

fis = addMF(fis, 'du', 'trimf', [-1 -1 -0.5], 'Name', 'NB');
fis = addMF(fis, 'du', 'trimf', [-1 -0.5 0], 'Name', 'NS');
fis = addMF(fis, 'du', 'trimf', [-0.5 0 0.5], 'Name', 'Z');
fis = addMF(fis, 'du', 'trimf', [0 0.5 1], 'Name', 'PS');
fis = addMF(fis, 'du', 'trimf', [0.5 1 1], 'Name', 'PB');

subplot(3,1,3);
plotmf(fis, "output", 1);axis([-1 1 0 1])
title('Variação do sinal de controle')
regras = [...
    % Erro (e) é NB
    "if e is NB and de is NB then du is NB"; ...
    "if e is NB and de is NS then du is NB"; ...
    "if e is NB and de is Z then du is NS"; ...
    "if e is NB and de is PS then du is NS"; ...
    "if e is NB and de is PB then du is Z"; ... 

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

    % Erro (e) é PB 
    "if e is PB and de is NB then du is Z"; ...  
    "if e is PB and de is NS then du is PB"; ...  
    "if e is PB and de is Z then du is PB"; ...
    "if e is PB and de is PS then du is PB"; ...
    "if e is PB and de is PB then du is PB"
];

fis = addRule(fis, regras); 
% Defuzzificação pelo centroide
fis.defuzzMethod = 'centroid';
% Gráfico superficie de controle
figure(2);
plotfis(fis);
figure(3);
gensurf(fis, [1 2], 1); 
title('Superfície de Controle');

%gerar arquivo .fis
writefis(fis, 'fuzzy_IN1_temperatura.fis');


% xlabel('Erro (e)');
% ylabel('Variação do Erro (de)');
% zlabel('Variação do Sinal de Controle (du)');