% gerar grafico composto com os resultados
clear;

% escolher temperatura ou umidade
prompt = 'Qual a variavel de análise? (1 - Temperatura, 2 - Umidade)\n';
var = input(prompt);

% Garante que o usuário escolha 1 ou 2
while (var ~= 1 && var ~= 2)
    disp('Opção inválida! Escolha 1 ou 2.');
    var = input(prompt);
end

% DEFINE OS CAMINHOS (Fora do while, agora que var é válida)
if var == 1
    filename_fuzzy = 'fuzzy/fuzzy_sem_toolbox/Planilhas/dados_2FLC_SISO_temperatura_patamares.csv';
    filename_zn    = 'planilhas/dados_PID_2ZN_SISO_temperatura.csv';
    filename_rele  = 'planilhas/dados_PID_astrom_SISO_temperatura.csv';
else % var só pode ser 2 aqui
    filename_fuzzy = 'fuzzy/fuzzy_sem_toolbox/Planilhas/dados_FLC_SISO_umidade_patamares.csv';
    filename_zn    = 'planilhas/dados_PID_2ZN_SISO_umidade.csv';
    filename_rele  = 'planilhas/dados_PID_astrom_SISO_umidade.csv';
end

% ==== LER DADOS DA PLANILHA ====
% Agora as variáveis filename existem com certeza!
[Tempo, r_fuzzy, y_fuzzy, u_fuzzy, erro_fuzzy] = ler_dados_csv(filename_fuzzy, var);
[~, ~, y_zn, u_zn, erro_zn] = ler_dados_csv(filename_zn, var);
[~, ~, y_rele, u_rele, erro_rele] = ler_dados_csv(filename_rele, var);

if var == 1
clf(figure(2))
figure(2);
% temperatura
subplot(2, 1, 1);
plot(Tempo/60, r_fuzzy, 'black--', 'LineWidth', 2);
hold on;
plot(Tempo/60, y_fuzzy, 'r', 'LineWidth', 2);
plot(Tempo/60, y_zn, 'b', 'LineWidth',.5);
plot(Tempo/60, y_rele, 'g', 'LineWidth', 1);

title('Saída de Temperatura');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('Referência', 'FLC', 'PID ZN', 'PID Astron');
grid on;
subplot(2, 1, 2);
plot(Tempo/60, u_fuzzy, 'r', 'LineWidth', 2);
hold on;

plot(Tempo/60, u_zn, 'b', 'LineWidth', .5);
plot(Tempo/60, u_rele, 'g', 'LineWidth', 1);

title('Sinal de Controle');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
legend('FLC', 'PID ZN', 'PID Astron');

 grid on;

elseif var == 2

% umidade
clf(figure(1))
figure(1);
subplot(2, 1, 1);

plot(Tempo/60, r_fuzzy, 'black--', 'LineWidth', 2);
hold on;
plot(Tempo/60, y_fuzzy, 'r', 'LineWidth', 1.5);
plot(Tempo/60, y_zn, 'b', 'LineWidth',.5);
plot(Tempo/60, y_rele, 'g', 'LineWidth', 1);
legend('Referência', 'FLC', 'PID ZN', 'PID Astron');

title('Saída de Umidade');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
grid on;
subplot(2, 1, 2);
plot(Tempo/60, u_fuzzy, 'r', 'LineWidth', 1.5);
hold on;

plot(Tempo/60, u_zn, 'b', 'LineWidth', .5);
plot(Tempo/60, u_rele, 'g', 'LineWidth', 1);
title('Sinal de Controle');
xlabel('Tempo (min)');
ylabel('Umidade Relativa (%)');
legend('FLC', 'PID ZN', 'PID Astron');

grid on;
end
