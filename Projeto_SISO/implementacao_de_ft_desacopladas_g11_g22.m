% -- SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;

qtde_amostras = 600;
T_amost = 18;

%% DEFININDO OS PATAMARES DE CADA ENTRADA
% Entrada 1 - Temperatura
r_1t = zeros(1, qtde_amostras); % Inicializa o vetor de referência
r_1t(1:qtde_amostras) = 30;
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36;
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 33;
% Entrada 2 - Umidade
% r_2u = zeros(1, qtde_amostras); % Inicializa o vetor de referência
% r_2u(1:qtde_amostras) = 50;
r_2u(1:qtde_amostras) = 50;
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 60;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;
%% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);
de = zeros(1, qtde_amostras);
d2e = zeros(1, qtde_amostras);
% Definindo as condições iniciais de 22°C e 50%
temp_inicial = 22;
umid_inicial = 50;

% Loop para preencher as condições iniciais (incluindo o erro)
for k = 1:qtde_amostras
    tempo(k) = k * T_amost;
    
    % Condições iniciais para temperatura (primeiros 5 pontos)
    if k <= 5
        y_1t(k) = temp_inicial;
        y_11t(k) = temp_inicial;
    end
    
    % Condições iniciais para umidade (primeiros 2 pontos)
    if k <= 2
        y_2u(k) = umid_inicial;
        y_22u(k) = umid_inicial;
    end
    
    % Calculo inicial do erro
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
end
% %% malha aberta temperatura
% for k = 6:qtde_amostras
%     y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * r_1t(k-4) + 0.00509 * r_1t(k-5);
%     y_1t(k) = y_11t(k);
% end
% 
% for k = 3:qtde_amostras
%     y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * r_2u(k-1) + 0.1869 * r_2u(k-2);
%     y_2u(k) = y_22u(k);
% end
%% LOOPS PARA MALHA FECHADA
% Este loop deve ser refatorado para que o cálculo do erro e da saída
% aconteça de forma sequencial dentro do mesmo loop.

for k = 6:qtde_amostras
    % malha fechada - Temperatura
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_1t(k) = y_11t(k);
    erro1(k) = r_1t(k) - y_1t(k);
end

for k = 3:qtde_amostras
    % malha fechada - Umidade
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * erro2(k-1) + 0.1869 * erro2(k-2);
    y_2u(k) = y_22u(k);
    erro2(k) = r_2u(k) - y_2u(k);
end

for k=6:qtde_amostras
    de(k) = erro1(k) - erro1(k-1);
    d2e(k) = de(k) - de(k-1);
end
% %MALHA FECHADA 

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
ylabel('Temperature (°C)');
xlabel('Time (min)');
title('Temperature Reference and Temperature Output', 'FontSize', 14);
legend('Temperature Reference', 'Temperature Output')
grid on
hold off

subplot(2,1,2) 
hold on
plot(tempo/60, r_2u, estilo_Ref, 'LineWidth', 1)
plot(tempo/60, y_2u,'Color',cor_saida, 'LineWidth', 1.5)
%plot(tempo/60, erro2,'Color', cor_erro, 'LineWidth', .5)
ylabel('Relative Humidity (%)');
xlabel('Time (min)');
title('Humidity Reference and Humidity Output', 'FontSize', 14);
legend('Humidity Reference', 'Humidity Output')
grid on
hold off


% figure(1)
% 
% subplot(2,1,1)
% hold on
% plot(tempo/60, r_1t,'r', 'LineWidth', 1.5)
% plot(tempo/60, y_1t,'b', 'LineWidth', 1.5)
% % plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
% % plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
% % plot(tempo/60, erro1,'b', 'LineWidth', 1)
% % legend('Entrada 1 - u_{1}');%, 'Erro 1 - e_{1MF}');
% % title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
% ylabel('Temperatura (°C)');
% xlabel('Tempo(min)');
% legend('Referência de Temperatura', 'Saída de Temperatura')
% % title('Saída de Temperatura Desacoplada sem Controlador - y_{11}(°C)');
% hold off
% 
% 
% 
% %-------------------
% subplot(2,1,2)
% 
% hold on
% plot(tempo/60, r_2u,'r', 'LineWidth', 1.5)
% plot(tempo/60, y_2u,'b', 'LineWidth', 1.5)
% % plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
% % plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
% % plot(tempo/60, erro1,'b', 'LineWidth', 1)
% % legend('Entrada 1 - u_{1}');%, 'Erro 1 - e_{1MF}');
% % title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
% ylabel('Umidade Relativa (%)');
% xlabel('Tempo(min)');
% legend('Referência de Umidade', 'Saída de Umidade')
% % title('Saída de Umidade Desacoplada sem Controlador - y_{11}(°C)');
% hold off

