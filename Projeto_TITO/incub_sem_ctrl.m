% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
%clear;clc; %close all;
qtde_amostras = 600;
T_amost = 18; % Tempo de amostragem em segundos
ganho = 1;
%% INICIALIZAÇÕES
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);

% Inicialize as saídas parciais e totais com zero, pois a resposta inicial
% será adicionada no final por superposição.
y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);

% --- DEFINIÇÃO DAS CONDIÇÕES INICIAIS DA SAÍDA TOTAL ---
% O autor do código original define os 7 primeiros pontos para r e y
y_1mft_inicial = 22; % Condição inicial da saída de temperatura
y_2mfu_inicial = 50; % Condição inicial da saída de umidade

% Os primeiros 7 pontos de tempo devem ser configurados com a referência
% e a saída inicial.
for k = 1:7 
    r_1t(k) = 30;
    r_2u(k) = 55;
    y_1t(k) = y_1mft_inicial;
    y_2u(k) = y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = (k) * T_amost;
end
%% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t(8:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(8:qtde_amostras/3) = 55; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 55;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 65;

%% LOOPS PARA SIMULAÇÃO
for k = 8:qtde_amostras
    % As equações de diferenças precisam ter acesso aos valores anteriores.
    % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
    % em cada passo, partindo de zero.
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - ganho*0.03556 * erro2(k-3) - ganho*0.1718 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + ganho*0.2455 * erro2(k-1) + ganho*1.869 * erro2(k-2);

    % As saídas do sistema são a soma das parcelas calculadas
    y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
    
    % Cálculo do erro para a próxima iteração
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    
    tempo(k) = k * T_amost;
end
% % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'Tables/incubadora_var_param100.csv';
% writetable(T, filename);
cor_saida   = [0, 0.4470, 0.7410]; % Azul
cor_erro = [0.8500, 0.3250, 0.0980]; % Laranja/Vermelho
estilo_Ref = 'k--';
%% PLOTAGEM DE GRÁFICOS
% MALHA FECHADA
figure
subplot(2,1,1) 
hold on
plot(tempo/60, r_1t,estilo_Ref, 'LineWidth', 1)
plot(tempo/60, y_1t,'Color',cor_saida, 'LineWidth', 1.5)
%plot(tempo/60, erro1,'Color', cor_erro, 'LineWidth', .5)
% ylabel('Temperature (°C)');
% xlabel('Time (min)');
% title('Temperature Reference and Temperature Output', 'FontSize', 14);
% legend('Temperature Reference', 'Temperature Output')ylabel('Temperature (°C)');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
title('Saída de Temperatura', 'FontSize', 14);
legend('Referência de Temperatura', 'Saída de Temperatura')
grid on
hold off

subplot(2,1,2) 
hold on
plot(tempo/60, r_2u, estilo_Ref, 'LineWidth', 1)
plot(tempo/60, y_2u,'Color',cor_saida, 'LineWidth', 1.5)
%plot(tempo/60, erro2,'Color', cor_erro, 'LineWidth', .5)
% ylabel('Relative Humidity (%)');
% xlabel('Time (min)');
% title('Humidity Reference and Humidity Output', 'FontSize', 14);
% legend('Humidity Reference', 'Humidity Output')
ylabel('Umidade Relativa (%UR)');
xlabel('Tempo (min)');
title('Saída de Umidade', 'FontSize', 14);
legend('Referência de Umidade', 'Saída de Umidade')
grid on
hold off

% 
