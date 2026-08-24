%==========================================================================
% CONTROLADOR FLC (Fuzzy Logic Controller) P/ TEMPERATURA
%==========================================================================
clear; clc; %close all;

qtde_amostras = 900;
T_amost = 18;

%% DEFININDO OS PATAMARES DE CADA ENTRADA
% Entrada 1 - Temperatura
r_1t = zeros(1, qtde_amostras); % Inicializa o vetor de referência
% r_1t(1:qtde_amostras) = 30;

r_1t(1:qtde_amostras) = 30;
r_1t(qtde_amostras /3+1:2*qtde_amostras/3) = 36;
r_1t(2*qtde_amostras/3+1:qtde_amostras) = 33;

%% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
e = zeros(1, qtde_amostras);
de = zeros(1, qtde_amostras);
du = zeros(1, qtde_amostras);
e_norm = zeros(1, qtde_amostras);
de_norm = zeros(1, qtde_amostras);
du_norm = zeros(1, qtde_amostras);

% Definindo as condições iniciais de 22°C e 50%
temp_inicial = 22;
umid_inicial = 50;
% CORREÇÃO: Cria um vetor de tempo de 0 até o final, com passo T_amost
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;% Loop para preencher as condições iniciais (incluindo o erro)
% Fatores de Escala das ENTRADAS (Sensibilidade)
Escala_e = 1/20;
Escala_de = .5; % Valor mais seguro após análise de overflow
Escala_du = 5;
for k = 1:5
    % tempo(k-1) = (k-1) * T_amost;
    y_11t(k) = temp_inicial;
    % u_1t(k) = 7.61;
    % Calculo inicial do erro
    e(k) = r_1t(k) - y_11t(k);
    e_norm(k) = e(k)*Escala_e;
end
% --- 4. FUZZY LOGIC SETUP ---
try
    fis = readfis('fuzzy_temperatura.fis');
    % plotfis(fis); % Descomente para visualizar a estrutura
catch ME
    error('Arquivo FIS não encontrado. Você precisa criar e salvar o FIS antes (rodar setup_fis.m).');
end

%% LOOPS PARA MALHA FECHADA
% Este loop deve ser refatorado para que o cálculo do erro e da saída
% aconteça de forma sequencial dentro do mesmo loop.

for k = 6:qtde_amostras
    % malha fechada - Temperatura
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
   % A. CÁLCULO DE ERRO E VARIAÇÃO DO ERRO
    % O erro atual é a diferença entre a Referência e a Saída ANTERIOR
    e(k) = r_1t(k) - y_11t(k); 
    e_norm(k) = e(k)*Escala_e;
    % Variação do Erro (Backward Difference)
    de(k) = e(k) - e(k-1); % Mantido, pois é o cálculo correto da derivada
    de_norm(k) = de(k)*Escala_de;
    
    %sinal de controle
    %OBS
    %tem erro aqui, a variacao de controle esta sempre sendo a mesma
    du_norm(k) = evalfis(fis, [e_norm(k), de_norm(k)]);
    du(k) = Escala_du*du_norm(k);
    u_1t(k) = u_1t(k-1) + du(k);
    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
   
 
end

% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
% (O código de plotagem permanece o mesmo)
clf(figure(4))
figure(4);
subplot(2, 1, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_11t, 'b', 'LineWidth', 2);
title('Resposta do Sistema com PID Fuzzy Puro');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'Saída');
grid on;
subplot(2, 1, 2);
plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
clf(figure(5))
figure(5);
subplot(2, 1, 1);
plot(tempo/60, e,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
subplot(2, 1, 2);
plot(tempo/60, de,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;


% ==== SALVAR DADOS EM PLANILHA ====
T = table(tempo(:), r_1t(:), y_11t(:), u_1t(:), e(:), ...
    'VariableNames', {'Tempo','Referencia_Temperatura', 'Saida_Temperatura', 'Sinal_Controle_Temperatura', 'Erro_Temperatura'});
%degrau
% filename = 'planilhas/dados_FLC_SISO_temperatura_degrau.csv';
%3patamares
filename = 'planilhas/dados_FLC_SISO_temperatura_patamares.csv';
writetable(T, filename);
disp(['Dados salvos em: ' filename]);

% ==== LER DADOS DA PLANILHA ====
T_lida = readtable(filename);

disp('Primeiras linhas dos dados lidos:');
disp(head(T_lida));

% Se quiser usar as variáveis separadas:
Tempo = T_lida.Tempo;
r_1t = T_lida.Referencia_Temperatura;
y_11t = T_lida.Saida_Temperatura;
u_1t = T_lida.Sinal_Controle_Temperatura;
e = T_lida.Erro_Temperatura;