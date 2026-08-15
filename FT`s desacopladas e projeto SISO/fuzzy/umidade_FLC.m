%==========================================================================
% CONTROLADOR FLC (Fuzzy Logic Controller) P/ UMIDADE
%==========================================================================
clear; clc; %close all;

qtde_amostras = 900;
T_amost = 18;

%% DEFININDO OS PATAMARES DE CADA ENTRADA
% Entrada 1 - Temperatura
r_2u= zeros(1, qtde_amostras); % Inicializa o vetor de referência
% r_2u(1:qtde_amostras) = 50;

r_2u(1:qtde_amostras/3) = 50; % Referência de 50
r_2u(qtde_amostras/3+1:2*qtde_amostras/3) = 60; 
r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55; 

%% INICIALIZAÇÕES
u_2u = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
e = zeros(1, qtde_amostras);
de = zeros(1, qtde_amostras);
du = zeros(1, qtde_amostras);
e_norm = zeros(1, qtde_amostras);
de_norm = zeros(1, qtde_amostras);
du_norm = zeros(1, qtde_amostras);

% Definindo a condição inicial de UR 50%
umid_inicial = 50;
% CORREÇÃO: Cria um vetor de tempo de 0 até o final, com passo T_amost
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;% Loop para preencher as condições iniciais (incluindo o erro)
% Fatores de Escala das ENTRADAS (Sensibilidade)
Escala_e = 1/30;
Escala_de = .1; % Valor mais seguro após análise de overflow
Escala_du = 20;
for k = 1:2
    % tempo(k-1) = (k-1) * T_amost;
    y_22u(k) = umid_inicial;
    % u_1t(k) = 7.61;
    % Calculo inicial do erro
    e(k) = r_2u(k) - y_22u(k);
    e_norm(k) = e(k)*Escala_e;
end
% --- 4. FUZZY LOGIC SETUP ---
try
    fis = readfis('fuzzy_umidade.fis');
    % plotfis(fis); % Descomente para visualizar a estrutura
catch ME
    error('Arquivo FIS não encontrado. Você precisa criar e salvar o FIS antes (rodar setup_fis.m).');
end

%% LOOPS PARA MALHA FECHADA
% Este loop deve ser refatorado para que o cálculo do erro e da saída
% aconteça de forma sequencial dentro do mesmo loop.

for k = 3:qtde_amostras
    % malha fechada - Temperatura
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
   % A. CÁLCULO DE ERRO E VARIAÇÃO DO ERRO
    % O erro atual é a diferença entre a Referência e a Saída ANTERIOR
    e(k) = r_2u(k) - y_22u(k); 
    e_norm(k) = e(k)*Escala_e;
    % Variação do Erro (Backward Difference)
    de(k) = (e(k) - e(k-1)); % Mantido, pois é o cálculo correto da derivada
    de_norm(k) = de(k)*Escala_de;
    
    %sinal de controle
    %OBS
    %tem erro aqui, a variacao de controle esta sempre sendo a mesma
    du_norm(k) = evalfis(fis, [e_norm(k), de_norm(k)]);
    du(k) = Escala_du*du_norm(k);
    u_2u(k) = u_2u(k-1) + du(k);
    if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
   
 
end

% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
% (O código de plotagem permanece o mesmo)
clf(figure(4))
figure(4);
subplot(2, 1, 1);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1);
hold on;
plot(tempo/60, y_22u, 'b', 'LineWidth', 1.5);
title('Resposta do Sistema com PID Fuzzy Puro');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída');
grid on;
subplot(2, 1, 2);
plot(tempo/60, u_2u, 'g', 'LineWidth', 1.5);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;


clf(figure(5))
figure(5);
subplot(2, 1, 1);
plot(tempo/60, e,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(2, 1, 2);
plot(tempo/60, de,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;

%==== SALVAR DADOS EM PLANILHA ====
T = table(tempo(:), r_2u(:), y_22u(:), u_2u(:), e(:), ...
    'VariableNames', {'Tempo', 'Referencia_Umidade', 'Saida_Umidade', 'Sinal_Controle_Umidade', 'Erro_Umidade'});

%degrau
% filename = 'planilhas/dados_FLC_SISO_umidade_degrau.csv';
%3patamares
filename = 'planilhas/dados_FLC_SISO_umidade_patamares.csv';
writetable(T, filename);
disp(['Dados salvos em: ' filename]);

% ==== LER DADOS DA PLANILHA ====
T_lida = readtable(filename);

disp('Primeiras linhas dos dados lidos:');
disp(head(T_lida));

% Se quiser usar as variáveis separadas:
Tempo = T_lida.Tempo;
r_2u = T_lida.Referencia_Umidade;
y_22u = T_lida.Saida_Umidade;
u_2u = T_lida.Sinal_Controle_Umidade;
erro2 = T_lida.Erro_Umidade;
