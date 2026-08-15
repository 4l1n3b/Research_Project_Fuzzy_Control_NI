% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;
clf(figure(1))
qtde_amostras = 400;
T_amostra = 18;

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
y_1t_inicial = 22; 
y_2u_inicial = 50;

for k = 1:7
    r_1t(k) = 30;
    r_2u(k) = 55;
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    tempo(k) = k*T_amostra;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
end
r_1t(8:qtde_amostras) = 30; 
r_2u(8:qtde_amostras) = 55; 

%% BLOCO 1: K_umid = 0.45
K_umid = 0.45;
a12_1 = -0.03556*K_umid; a12_2 = -0.1718*K_umid;
a22_1 = 0.2455*K_umid; a22_2 = 1.869*K_umid;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k)+ y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = k * T_amostra;
end

figure(1)
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

%% BLOCO 2: K_umid = 0.529
K_umid = 0.529;
a12_1 = -0.03556*K_umid; a12_2 = -0.1718*K_umid;
a22_1 = 0.2455*K_umid; a22_2 = 1.869*K_umid;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k)+ y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = k * T_amostra;
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

%% BLOCO 3: K_umid = 0.531
K_umid = 0.531;
a12_1 = -0.03556*K_umid; a12_2 = -0.1718*K_umid;
a22_1 = 0.2455*K_umid; a22_2 = 1.869*K_umid;

for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * erro1(k-4) + 0.00509 * erro1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * erro1(k-6) - 0.007485 * erro1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k)+ y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = k * T_amostra;
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