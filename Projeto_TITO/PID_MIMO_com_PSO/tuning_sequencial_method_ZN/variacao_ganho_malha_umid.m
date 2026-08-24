% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;

qtde_amostras = 300;
T_amostra = 18;


%% INICIALIZAÇÕES
u_1t = zeros(1, qtde_amostras);
u_2u = zeros(1, qtde_amostras);
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
% Este loop inicializa as variáveis para os primeiros 7 pontos de tempo.
% As condições iniciais de 20°C e 17.3% são definidas aqui para ENTRADAS E SAÍDAS.
for k = 1:7
    % As entradas são os setpoints de referência.
    r_1t(k) = 30;
    r_2u(k) = 50;
    % As saídas do sistema inicializadas com os mesmos
    % valores das entradas para simular as condições iniciais.
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    
    % Inicialização do vetor de tempo e erro. Com a saída = entrada,
    % o erro inicial é zero, como esperado para um estado de equilíbrio.
    tempo(k) = k*T_amostra;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
end
r_1t(8:qtde_amostras) = 30; 
% r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
% r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
r_2u(8:qtde_amostras) = 50; 
% r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
% r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;
%% LOOPS PARA MALHA ABERTA E FECHADA
%variaveis da ft para testar a estabilidade
K_umid = 0.501;
a12_1 = -0.03556*K_umid;
a12_2 = -0.1718*K_umid;
a22_1 = 0.2455*K_umid;
a22_2 = 1.869*K_umid;
% Loop para avaliar as alteraçoes do valor de K
%### Ziegler_nichols Frequencial da malha de temperatura
K_crt=4.46;

T_crt=234; %em segundos. Equivale à 4.2 min
% 
 Kp=0.6*K_crt;
 Ti=0.5*T_crt;
 Td=0.125*T_crt;

% %M?toro Trapezoidal
Ki = Kp/Ti;
Kd = Kp*Td;


g0 = Kp + ((Ki*T_amostra)/2) + (Kd/T_amostra);
g1 = ((Ki*T_amostra)/2) - Kp - ((2*Kd)/T_amostra);
g2 = Kd/T_amostra;
%malha fechada
for k = 8:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) + a12_1 * erro2(k-3) + a12_2 * erro2(k-4);
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + a22_1 * erro2(k-1) + a22_2 * erro2(k-2);
    
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;

    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    u_1t(k) = u_1t(k-1) + g0 * erro1(k) + g1 * erro1(k-1) + g2 * erro1(k-2);
    if u_1t(k) > 100
        u_1t(k) = 100;
    end
    if u_1t(k) < 0
        u_1t(k) = 0;
    end
    tempo(k) = k * T_amostra;

end

%% PLOTAGEM DE GRÁFICOS


%MALHA FECHADA 
figure(2)

% Primeiro subplot – Saída y_1
subplot(2,2,1) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1)
ylabel('r_{1}(°C)');
xlabel('Tempo(min)');
title('Referência de Temperatura - r_{1t}(k)');
text((310*T_amostra/60),33,'\leftarrowr_{1t}');
hold off

%------------
subplot(2,2,2) 
hold on
plot(tempo/60, r_2u, 'g', 'LineWidth', 1)
ylabel('r_{2}(%)');
xlabel('Tempo(min)');
title('Referência de Umidade - r_{2u}(k)');
text((610*T_amostra/60),53,'\leftarrowr_{2u}');
hold off
%-------------------
subplot(2,2,3) 
hold on
plot(tempo/60, y_1t,'b', 'LineWidth', 1)
% plot(tempo/60, erro1,'g', 'LineWidth', 1)
ylabel('Temperatura (°C)');
xlabel('Tempo(min)');
% title('Saída e Erro de Temperatura - y_{1t} e e_{1t}');
title('Saída de Temperatura - y_{1t}');
% legend('y_{1t}','e_{1t}')
hold off
%-------------------
subplot(2,2,4)
hold on
plot(tempo/60, y_2u,'m', 'LineWidth', 1)
% plot(tempo/60, erro2,'g', 'LineWidth', 1)
% title('Saída e Erro de Umidade - y_{2u} e e_{2u}')
title('Saída de Umidade - y_{2u}')

ylabel('Umidade Relativa (%)');
xlabel('Tempo(min)');
% legend('y_{2u}','e_{2u}')

hold off
% %-------------------
% subplot(3,2,5) 
% hold on
% plot(tempo/60, erro1,'b', 'LineWidth', 1)
% ylabel('e_{1}(°C)');
% xlabel('Tempo(min)');
% title('Erro de Temperatura - e_{1t}');
% hold off
% %-------------------
% subplot(3,2,6)
% hold on
% plot(tempo/60, erro2,'y', 'LineWidth', 1)
% title('Erro de Umidade - e_{2u}')
% ylabel('e_{2}(%)');
% xlabel('Tempo(min)');
% hold off
