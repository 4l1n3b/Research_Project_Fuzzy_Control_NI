% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;
qtde_amostras = 500;
T_amost = 18;
%% INICIALIZAÇÕES
y_11t = zeros(1, qtde_amostras);
y_12u = zeros(1, qtde_amostras);
y_21t = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
y_1t = zeros(1, qtde_amostras);
y_2u = zeros(1, qtde_amostras);
erro1 = zeros(1, qtde_amostras);
erro2 = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);
r_1t = zeros(1, qtde_amostras);
r_2u = zeros(1, qtde_amostras);
y_1t_inicial = 22; % Condição inicial da saída de temperatura
y_2u_inicial = 50;

for k = 1:7
    r_1t(k) = 30;
    r_2u(k) = 55;
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    tempo(k) = k*T_amost;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
end
r_1t(8:qtde_amostras) = 30; 
r_2u(8:qtde_amostras) = 55; 

%% PARTE 1: K_temp = 4
K_temp = 4;
a11_1 = 0.08796*K_temp; a11_2 = 0.00509*K_temp;
a21_1 = - 0.1294*K_temp; a21_2 = - 0.007485*K_temp;
K_umid = 0.1;
a12_1 = -0.03556*K_umid; a12_2 = -0.1718*K_umid;
a22_1 = 0.2455*K_umid; a22_2 = 1.869*K_umid;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + a11_1 * erro1(k-4) + a11_2 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) + a21_1 * erro1(k-6) + a21_2 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k)=k*T_amost;
end

figure(2)
subplot(3,2,1) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1)
plot(tempo/60, y_1t,'b', 'LineWidth', 1)
ylabel('Temperatura (°C)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(a)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off

subplot(3,2,2) 
hold on
plot(tempo/60, r_2u, 'g', 'LineWidth', 1)
plot(tempo/60, y_2u,'m', 'LineWidth', 1)
ylabel('Umidade Relativa (%)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(b)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off

%% PARTE 2: K_temp = 4.507
K_temp = 4.507;
a11_1 = 0.08796*K_temp; a11_2 = 0.00509*K_temp;
a21_1 = - 0.1294*K_temp; a21_2 = - 0.007485*K_temp;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + a11_1 * erro1(k-4) + a11_2 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) + a21_1 * erro1(k-6) + a21_2 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k)=k*T_amost;
end

subplot(3,2,3) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1)
plot(tempo/60, y_1t,'b', 'LineWidth', 1)
ylabel('Temperatura (°C)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(c)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off

subplot(3,2,4) 
hold on
plot(tempo/60, r_2u, 'g', 'LineWidth', 1)
plot(tempo/60, y_2u,'m', 'LineWidth', 1)
ylabel('Umidade Relativa (%)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(d)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off

%% PARTE 3: K_temp = 4.53
K_temp = 4.53;
a11_1 = 0.08796*K_temp; a11_2 = 0.00509*K_temp;
a21_1 = - 0.1294*K_temp; a21_2 = - 0.007485*K_temp;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + a11_1 * erro1(k-4) + a11_2 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) + a21_1 * erro1(k-6) + a21_2 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k)=k*T_amost;
end

subplot(3,2,5) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1)
plot(tempo/60, y_1t,'b', 'LineWidth', 1)
ylabel('Temperatura (°C)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(e)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off

subplot(3,2,6) 
hold on
plot(tempo/60, r_2u, 'g', 'LineWidth', 1)
plot(tempo/60, y_2u,'m', 'LineWidth', 1)
ylabel('Umidade Relativa (%)'); xlabel('Tempo(min)');
legend('Referência', 'Saída')
title('(f)', 'Units', 'normalized', 'Position', [0.5, -0.3], 'FontSize', 10);
hold off