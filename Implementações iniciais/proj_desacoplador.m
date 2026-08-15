% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; close all;

qtde_amostras = 600;
T_amost = 18;

%% DEFININDO OS PATAMARES DE CADA ENTRADA
% Entrada 1 - Temperatura
u_1t(1:qtde_amostras) = 30; 
u_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 30; 
u_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
% Entrada 2 - Umidade
u_2u(1:qtde_amostras/2) = 55; 
u_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 65;
u_2u((2*qtde_amostras/3+1):qtde_amostras) = 65;
%% CÁLCULO DAS NOVAS REFERÊNCIAS - DESACOPLAMENTO
v1 = u_1t;  % Referência para saída 1
v2 = u_2u;  % Referência para saída 2

% INICIALIZAÇÃO DE VARIÁVEIS DESACOPLADAS
u1_desc = zeros(1, qtde_amostras);
u2_desc = zeros(1, qtde_amostras);

% APLICAÇÃO DO DESACOPLADOR
for k = 1:qtde_amostras
    u1_desc(k) = 0.4345 * v1(k) + 0.0606 * v2(k);
    u2_desc(k) = 0.8253 * v1(k) + 0.5652 * v2(k);
end

%% INICIALIZAÇÕES
for k = 1:8
    y_11t(k) = 0;
    y_12u(k) = 0;
    y_21t(k) = 0;
    y_22u(k) = 0;
    y_1t(k) = y_11t(k) + y_12u(k);
    y_2u(k) = y_21t(k) + y_22u(k);
    y_11mft(k) = 0;
    y_12mfu(k) = 0;
    y_21mft(k) = 0;
    y_22mfu(k) = 0;
    y_1mft(k) = y_11mft(k) + y_12mfu(k);
    y_2mfu(k) = y_21mft(k) + y_22mfu(k);
    tempo(k)=k*T_amost;
    erro1(k) = u1_desc(k) - y_1mft(k);
    erro2(k) = u2_desc(k) - y_2mfu(k);
end
%% LOOPS PARA MALHA ABERTA E FECHADA

% LoopS para observar a resposta das saidas e observar o acoplamento das
% malhas

%mALHA ABERTA
for k = 8:qtde_amostras
y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u1_desc(k-4) + 0.00509 * u1_desc(k-5);
y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u2_desc(k-3) - 0.01718 * u2_desc(k-4);
y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u1_desc(k-6) - 0.007485 * u1_desc(k-7);
y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u2_desc(k-1) + 0.1869 * u2_desc(k-2);

y_1t(k) = y_11t(k) + y_12u(k);
y_2u(k) = y_21t(k) + y_22u(k);

tempo(k)=k*T_amost;
end

%malha fechada
for k = 8:qtde_amostras
y_11mft(k) = 0.9678 * y_11mft(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
y_12mfu(k) = 0.9331 * y_12mfu(k-1) - 0.003556 * erro2(k-3) - 0.01718 * erro2(k-4);
y_21mft(k) = 0.9676 * y_21mft(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
y_22mfu(k) = 0.9048 * y_22mfu(k-1) + 0.02455 * erro2(k-1) + 0.1869 * erro2(k-2);
y_1mft(k) = y_11mft(k) + y_12mfu(k);
y_2mfu(k) = y_21mft(k) + y_22mfu(k);
erro1(k) = u1_desc(k) - y_1mft(k);
erro2(k) = u2_desc(k) - y_2mfu(k);
tempo(k)=k*T_amost;

end

%% PLOTAGEM DE GRÁFICOS

%MALHA ABERTA
figure(1)
% Primeiro subplot – Saída y_1
subplot(2,1,1) 
hold on
plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
plot(tempo/60, y_1t,'b', 'LineWidth', 1)
legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MA}');
title('Resposta da Saída 1 em Malha Aberta - y_{1MA}')
ylabel('Temperatura(°C)');
xlabel('Tempo(min)');
hold off

% Segundo subplot – Saída y_2
subplot(2,1,2)
hold on
plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
plot(tempo/60, y_2u,'m', 'LineWidth', 1)
legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 2 - y_{2MA}');
title('Resposta da Saída 2 em Malha Aberta - y_{2MA}')
ylabel('Umidade(%)');
xlabel('Tempo(min)');
hold off

%MALHA FECHADA 
figure(2)

% Primeiro subplot – Saída y_1
subplot(2,1,1) 
hold on
plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
plot(tempo/60, erro1,'b', 'LineWidth', 1)
legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MF}', 'Erro 1 - e_{1MF}');
title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
ylabel('Temperatura(°C)');
xlabel('Tempo(min)');
hold off

% Segundo subplot – Saída y_2
subplot(2,1,2)
hold on
plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
plot(tempo/60, y_2mfu,'m', 'LineWidth', 1)
plot(tempo/60, erro2,'b', 'LineWidth', 1)
legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 2 - y_{2MF}','Erro 2 - e_{2MF}');
title('Resposta da Saída 2 em Malha Fechada - y_{2MF}')
ylabel('Umidade(%)');
xlabel('Tempo(min)');
hold off
