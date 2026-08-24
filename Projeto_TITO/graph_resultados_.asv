% gerar grafico composto com os resultados TITO
clear; clc;

% % escolher temperatura ou umidade
% prompt = 'Qual a variavel de análise? (1 - Temperatura, 2 - Umidade)\n';
% var = input(prompt);
% 
% % Garante que o usuário escolha 1 ou 2
% while (var ~= 1 && var ~= 2)
%     disp('Opção inválida! Escolha 1 ou 2.');
%     var = input(prompt);
% end

% DEFINE OS CAMINHOS (Fora do while, agora que var é válida)
% if var == 1
    filename_fuzzy = 'fuzzy/fuzzy_sem_toolbox/Planilhas/dados_FLC_SISO_temperatura_patamares.csv';
    filename_zn    = 'planilhas/dados_PID_ZN_SISO_temperatura.csv';
    filename_rele  = 'planilhas/dados_PID_astrom_SISO_temperatura.csv';
% else % var só pode ser 2 aqui
    % filename_fuzzy = 'fuzzy/fuzzy_sem_toolbox/Planilhas/dados_FLC_SISO_umidade_patamares.csv';
    % filename_zn    = 'planilhas/dados_PID_ZN_SISO_umidade.csv';
    % filename_rele  = 'planilhas/dados_PID_astrom_SISO_umidade.csv';
% end

% ==== LER DADOS DA PLANILHA ====
% Agora as variáveis filename existem com certeza!
[Tempo, r_fuzzy, y_fuzzy, u_fuzzy, erro_fuzzy] = ler_dados_csv(filename_fuzzy, var);
[~, ~, y_zn, u_zn, erro_zn] = ler_dados_csv(filename_zn, var);
[~, ~, y_rele, u_rele, erro_rele] = ler_dados_csv(filename_rele, var);
% disp(head(T_lida));
% 
% Se quiser usar as variáveis separadas:
% tempo = T_fuzzy.Tempo;
% r_fuzzy = T_fuzzy.Referencia_Temperatura;
% y_fuzzy = T_fuzzy.Saida_Temperatura;
% u_fuzzy = T_fuzzy.Sinal_Controle_Temperatura;
% erro_fuzzy = T_fuzzy.Erro_Temperatura;
% r_2u_fuzzy = T_fuzzy.Referencia_Umidade;
% y_2u_fuzzy = T_fuzzy.Saida_Umidade;
% u_2u_fuzzy = T_fuzzy.Sinal_Controle_Umidade;
% % erro2_fuzzy = T_fuzzy.Erro_Umidade;

% zn
% r_1t_zn = T_zn.Referencia_Temperatura;
% y_zn = T_zn.Saida_Temperatura;
% u_zn = T_zn.Sinal_Controle_Temperatura;
% erro_zn = T_zn.Erro_Temperatura;
% r_2u_zn = T_zn.Referencia_Umidade;
% y_2u_zn = T_zn.Saida_Umidade;
% u_2u_zn = T_zn.Sinal_Controle_Umidade;
% % erro2_zn = T_zn.Erro_Umidade;
%astom
% r_1t_rele = T_rele.Referencia_Temperatura;
% y_rele = T_rele.Saida_Temperatura;
% u_rele = T_rele.Sinal_Controle_Temperatura;
% erro_rele = T_rele.Erro_Temperatura;
% r_2u_rele = T_rele.Referencia_Umidade;
% y_2u_rele = T_rele.Saida_Umidade;
% u_2u_rele = T_rele.Sinal_Controle_Umidade;
% erro2_rele = T_rele.Erro_Umidade;

% (O código de plotagem permanece o mesmo)
clf(figure(1))
figure(1);
% temperatura
subplot(2, 1, 1);
plot(Tempo/60, r_fuzzy, 'black--', 'LineWidth', 1);
hold on;
plot(Tempo/60, y_fuzzy, 'r', 'LineWidth', 1);
plot(Tempo/60, y_zn, 'b', 'LineWidth',1);
plot(Tempo/60, y_rele, 'g', 'LineWidth', 1);

title('Saída de Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'FLC', 'PID ZN', 'PID Astron');
grid on;
subplot(2, 1, 2);
plot(Tempo/60, u_fuzzy, 'r', 'LineWidth', 1);
hold on;

plot(Tempo/60, u_zn, 'b', 'LineWidth', 1);
plot(Tempo/60, u_rele, 'g', 'LineWidth', 1);

title('Sinal de Controle - Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('FLC', 'PID ZN', 'PID Astron');

% grid on;
% 
% % umidade
% subplot(2, 2, 3);
% plot(tempo/60, r_2u_fuzzy, 'black--', 'LineWidth', 1.5);
% hold on;
% plot(tempo/60, y_2u_fuzzy, 'r', 'LineWidth', 0.5);
% plot(tempo/60, y_2u_zn, 'b', 'LineWidth', 0.5);
% plot(tempo/60, y_2u_rele, 'g', 'LineWidth', 0.5);
% legend('Referência', 'FLC', 'PID ZN', 'PID Astron');
% 
% title('Saída de Umidade');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% grid on;
% subplot(2, 2, 4);
% plot(tempo/60, u_2u_fuzzy, 'r', 'LineWidth', 0.5);
% hold on;
% plot(tempo/60, u_2u_zn, 'b', 'LineWidth', 0.5);
% plot(tempo/60, u_2u_rele, 'g', 'LineWidth', 0.5);
% title('Sinal de Controle - Umidade');
% xlabel('Tempo (min)');
% ylabel('Umidade Relativa (%)');
% legend('FLC', 'PID ZN', 'PID Astron');
% 
% grid on;

