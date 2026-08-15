%==========================================================================
% CONTROLADOR FUZZY P/ MODELO DE INCUBADORA
%==========================================================================
clear; clc; %close all;

qtde_amostras = 900;
T_amost = 18;

%% INICIALIZAÇÕES
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);

y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
% tempo = zeros(1, qtde_amostras);

% Definindo as condições iniciais de 22°C e 50%
y_1t_inicial = 22; % Condição inicial da saída de temperatura
y_2u_inicial = 50; % Condição inicial da saída de umidade

% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t(1:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(1:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;

% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);
de1 = zeros(1, qtde_amostras);
de2 = zeros(1, qtde_amostras);
du1 = zeros(1, qtde_amostras);
du2 = zeros(1, qtde_amostras);
erro1_norm = zeros(1, qtde_amostras);
de1_norm = zeros(1, qtde_amostras);
du1_norm = zeros(1, qtde_amostras);
erro2_norm = zeros(1, qtde_amostras);
de2_norm = zeros(1, qtde_amostras);
du2_norm = zeros(1, qtde_amostras);
tempo = 0:T_amost:(qtde_amostras-1)*T_amost;
%Normalização - Temperatura
Escala_e1 = 1/25;
Escala_de1 = .5; 
Escala_du1 = 5;
%Normalização - Umidade
Escala_e2 = 1/22;
Escala_de2 = .4; 
Escala_du2 = 8;

for k = 1:7 
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro1_norm(k) = erro1(k)*Escala_e1;
    erro2(k) = r_2u(k) - y_2u(k);
    erro2_norm(k) = erro2(k)*Escala_e2;
    tempo(k) = (k) * T_amost;
end


% Load do arquivo .fis
try
    fuzzy1 = readfis('fuzzy_IN1_temperatura.fis');
catch ME
    error('Arquivo FIS não encontrado.');
end
try
    fuzzy2 = readfis('fuzzy_IN2_umidade.fis');
catch ME
    error('Arquivo FIS não encontrado.');
end
%% LOOP DE CONTROLE

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);
    
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
    
    % Saída do Sistema
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    
    % Cálculo do erro 
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    erro1_norm(k) = erro1(k)*Escala_e1;
    erro2_norm(k) = erro2(k)*Escala_e2;

    % Variação do Erro 
    de1(k) = erro1(k) - erro1(k-1); 
    de1_norm(k) = de1(k)*Escala_de1;
    de2(k) = erro2(k) - erro2(k-1); 
    de2_norm(k) = de2(k)*Escala_de2;
    %sinal de controle

    e1_fuzzy = max(-1, min(1, erro1_norm(k)));
    de1_fuzzy = max(-1, min(1, de1_norm(k)));
    e2_fuzzy = max(-1, min(1, erro2_norm(k)));
    de2_fuzzy = max(-1, min(1, de2_norm(k)));

    % Execução do controlador
    du1_norm(k) = evalfis(fuzzy1, [e1_fuzzy, de1_fuzzy]);
    du2_norm(k) = evalfis(fuzzy2, [e2_fuzzy, de2_fuzzy]);
    du1(k) = Escala_du1*du1_norm(k);
    du2(k) = Escala_du2*du2_norm(k);
    u_1t(k) = u_1t(k-1) + du1(k);
    u_2u(k) = u_2u(k-1) + du2(k);

    if u_1t(k) > 100
        u_1t(k) = 100;
    elseif u_1t(k) < 0
        u_1t(k) = 0;
    end
   if u_2u(k) > 100
        u_2u(k) = 100;
    elseif u_2u(k) < 0
        u_2u(k) = 0;
    end
 
end

% ----------------------------------------------------
% 7. PLOTAGEM DOS RESULTADOS
% ----------------------------------------------------
clf(figure(4))
figure(4);
% temperatura
subplot(4, 2, 1);
plot(tempo/60, r_1t, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_1t, 'b', 'LineWidth', 2);
title('Saída de Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'Saída');
grid on;
subplot(4, 2, 3);
plot(tempo/60, u_1t, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;

subplot(4, 2, 5);
plot(tempo/60, erro1,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
subplot(4, 2, 7);
plot(tempo/60, de1,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
grid on;
% umidade
subplot(4, 2, 2);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_2u, 'b', 'LineWidth', 2);
title('Saída de Umidade');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída');
grid on;
subplot(4, 2, 4);
plot(tempo/60, u_2u, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;

subplot(4, 2, 6);
plot(tempo/60, erro2,'b', 'LineWidth', 1.5);
title('Erro (e)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(4, 2, 8);
plot(tempo/60, de2,'r', 'LineWidth', 1.5);
title('Variação do Erro (de)');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;

% ==== SALVAR DADOS EM PLANILHA ====
T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), u_1t(:), u_2u(:), erro1(:), erro2(:), ...
    'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade', 'Sinal_Controle_Temperatura', 'Sinal_Controle_Umidade','Erro_Temperatura', 'Erro_Umidade'});

filename = 'planilhas/dados_FLC_TITO_degrau.csv';
writetable(T, filename);
disp(['Dados salvos em: ' filename]);

% ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
% % 
% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_1t = T_lida.Referencia_Temperatura;
% y_1t = T_lida.Saida_Temperatura;
% u_1t = T_lida.Sinal_Controle_Temperatura;
% erro1 = T_lida.Erro_Temperatura;
% r_2u= T_lida.Referencia_Umidade;
% y_2u = T_lida.Saida_Umidade;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro2 = T_lida.Erro_Umidade;