% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;
qtde_amostras = 900;
T_amost = 18; % Tempo de amostragem em segundos

%% INICIALIZAÇÕES
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);

% Inicialize as saídas parciais e totais com zero, pois a resposta inicial
% será adicionada no final por superposição.
y_1mft = zeros(1, qtde_amostras);
y_2mfu = zeros(1, qtde_amostras);
y_11mft = zeros(1, qtde_amostras);
y_12mfu = zeros(1, qtde_amostras);
y_21mft = zeros(1, qtde_amostras);
y_22mfu = zeros(1, qtde_amostras);
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
    r_2u(k) = 50;
    y_1mft(k) = y_1mft_inicial;
    y_2mfu(k) = y_2mfu_inicial;
    erro1(k) = r_1t(k) - y_1mft(k);
    erro2(k) = r_2u(k) - y_2mfu(k);
    tempo(k) = (k) * T_amost;
end
%% DEFININDO OS PATAMARES DE CADA ENTRADA
r_1t(8:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(8:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;

%% LOOPS PARA SIMULAÇÃO
for k = 8:qtde_amostras
    % As equações de diferenças precisam ter acesso aos valores anteriores.
    % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
    % em cada passo, partindo de zero.
    y_11mft(k) = 0.9678 * y_11mft(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_12mfu(k) = 0.9331 * y_12mfu(k-1) - 0.003556 * erro2(k-3) - 0.01718 * erro2(k-4);
    y_21mft(k) = 0.9676 * y_21mft(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
    y_22mfu(k) = 0.9048 * y_22mfu(k-1) + 0.02455 * erro2(k-1) + 0.1869 * erro2(k-2);
    
    % As saídas do sistema são a soma das parcelas calculadas
    y_1mft(k) = y_11mft(k) + y_12mfu(k) + y_1mft_inicial;
    y_2mfu(k) = y_21mft(k) + y_22mfu(k) + y_2mfu_inicial;
    
    % Cálculo do erro para a próxima iteração
    erro1(k) = r_1t(k) - y_1mft(k);
    erro2(k) = r_2u(k) - y_2mfu(k);
    
    tempo(k) = k * T_amost;
end


%% PLOTAGEM DE GRÁFICOS
% MALHA FECHADA
figure(2)
title('Saídas do Sistema sem Controlador');
subplot(2,1,1) 
hold on
plot(tempo/60, r_1t,'b', 'LineWidth', 1.5)
plot(tempo/60, y_1mft,'r', 'LineWidth', 1.5)
plot(tempo/60, erro1, 'g', 'LineWidth', 1.5)
ylabel('Temperatura (°C)');
xlabel('Tempo(min)');
legend('Referência de Temperatura', 'Saída de Temperatura', 'Erro');
grid on
hold off

subplot(2,1,2) 
hold on
plot(tempo/60, r_2u, 'b', 'LineWidth', 1.5)
plot(tempo/60, y_2mfu,'r', 'LineWidth', 1.5)
plot(tempo/60, erro2, 'g', 'LineWidth', 1.5)
ylabel('Umidade (%)');
xlabel('Tempo(min)');
legend('Referência de Umidade', 'Saída de Umidade', 'Erro');
grid on
hold off



