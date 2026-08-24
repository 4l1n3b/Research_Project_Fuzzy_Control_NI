% gerar grafico composto com os resultados
clear; clc;
filename_fuzzy = 'fuzzy_sem_toolbox/planilhas/dados_FLC_TITO_patamares_nao_norm.csv';
filename_zn = 'tuning_sequencial_method_ZN/planilhas/dados_PID_ZN_incubadora.csv';
filename_rele = 'tuning_sequencial_method_RELE/dados_PID_ASTROM_incubadora.csv';

% ==== LER DADOS DA PLANILHA ====
T_fuzzy = readtable(filename_fuzzy);
T_zn = readtable(filename_zn);
T_rele = readtable(filename_rele);

% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
% 
% Se quiser usar as variáveis separadas:
tempo = T_fuzzy.Tempo;
r_1t_fuzzy = T_fuzzy.Referencia_Temperatura;
y_1t_fuzzy = T_fuzzy.Saida_Temperatura;
u_1t_fuzzy = T_fuzzy.Sinal_Controle_Temperatura;
% erro1_fuzzy = T_fuzzy.Erro_Temperatura;
r_2u_fuzzy = T_fuzzy.Referencia_Umidade;
y_2u_fuzzy = T_fuzzy.Saida_Umidade;
u_2u_fuzzy = T_fuzzy.Sinal_Controle_Umidade;
% erro2_fuzzy = T_fuzzy.Erro_Umidade;

% zn
% r_1t_zn = T_zn.Referencia_Temperatura;
y_1t_zn = T_zn.Saida_Temperatura;
u_1t_zn = T_zn.Sinal_Controle_Temperatura;
% erro1_zn = T_zn.Erro_Temperatura;
% r_2u_zn = T_zn.Referencia_Umidade;
y_2u_zn = T_zn.Saida_Umidade;
u_2u_zn = T_zn.Sinal_Controle_Umidade;
% erro2_zn = T_zn.Erro_Umidade;
%astom
% r_1t_rele = T_rele.Referencia_Temperatura;
y_1t_rele = T_rele.Saida_Temperatura;
u_1t_rele = T_rele.Sinal_Controle_Temperatura;
% erro1_rele = T_rele.Erro_Temperatura;
% r_2u_rele = T_rele.Referencia_Umidade;
y_2u_rele = T_rele.Saida_Umidade;
u_2u_rele = T_rele.Sinal_Controle_Umidade;
% erro2_rele = T_rele.Erro_Umidade;

% Cores e Estilos
cor_PID   = [0, 0.4470, 0.7410]; % Azul
cor_Fuzzy = [0.8500, 0.3250, 0.0980]; % Laranja/Vermelho
estilo_Ref = 'k--';
% (O código de plotagem permanece o mesmo)
clf(figure(1))
figure(1);
% temperatura
subplot(2, 1, 1);
plot(Tempo/60, r_fuzzy, estilo_Ref, 'LineWidth', 1.5);
hold on;
plot(Tempo/60, y_fuzzy, 'Color', cor_PID, 'LineWidth', 1.2);
plot(Tempo/60, y_zn,  'Color', cor_Fuzzy, 'LineWidth', 1.2);
%plot(Tempo/60, y_rele, 'g', 'LineWidth', 1);

title('Saída de Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'FLC', 'PID ZN');
grid on;
subplot(2, 1, 2);
plot(Tempo/60, u_fuzzy, 'Color', cor_PID, 'LineWidth', 1.2);
hold on;

plot(Tempo/60, u_zn, 'Color', cor_Fuzzy, 'LineWidth', 1.2);
%plot(Tempo/60, u_rele, 'g', 'LineWidth', 1);

title('Sinal de Controle - Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('FLC', 'PID ZN');

grid on;

% umidade
subplot(2, 2, 3);
plot(tempo/60, r_2u_fuzzy, 'black--', 'LineWidth', 1.5);
hold on;
plot(tempo/60, y_2u_fuzzy, 'Color', cor_Fuzzy, 'LineWidth', 1.2);
plot(tempo/60, y_2u_zn,'Color', cor_Fuzzy, 'LineWidth', 1.2);
legend('Referência', 'FLC', 'PID ZN');

title('Saída de Umidade');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(2, 2, 4);
plot(tempo/60, u_2u_fuzzy, 'r', 'LineWidth', 0.5);
hold on;
plot(tempo/60, u_2u_zn, 'b', 'LineWidth', 0.5);
plot(tempo/60, u_2u_rele, 'g', 'LineWidth', 0.5);
title('Sinal de Controle - Umidade');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
legend('FLC', 'PID ZN', 'PID Astron');

grid on;
