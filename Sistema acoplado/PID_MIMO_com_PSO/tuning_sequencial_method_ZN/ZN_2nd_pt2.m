%C?digo de Implementa PID ZN

varlist = {'r','u','y', 'tempo'};

clear(varlist{:})

clf(figure(2))

%Limpar vari?veis do Workspace - INICIO



T_amostra= 18; %Determina??o do per?odo de amostragem

qtde_amostras = 600;

% Inicializações

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

% --- DEFINIÇÃO DAS CONDIÇÕES INICIAIS DA SAÍDA TOTAL ---

% O autor do código original define os 7 primeiros pontos para r e y

y_1t_inicial = 22; % Condição inicial da saída de temperatura

y_2u_inicial = 50; % Condição inicial da saída de umidade



% Os primeiros 7 pontos de tempo devem ser configurados com a referência

% e a saída inicial.

for k = 1:7

    r_1t(k) = 30;

    u_1t(k) = 0;

    r_2u(k) = 50;

    y_1t(k) = y_1t_inicial;

    y_2u(k) = y_2u_inicial;


    erro1(k) = r_1t(k) - y_1t(k);

    % erro2(k) = r_2u(k) - y_2u(k);

    tempo(k) = (k) * T_amostra;

end

%% DEFININDO OS PATAMARES DE CADA ENTRADA

% r_1t(1:qtde_amostras) = 30;

r_1t(8:qtde_amostras/3) = 30;

r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36;

r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;

% r_2u(1:qtde_amostras) = 55;

r_2u(8:qtde_amostras/3) = 50;

r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;

r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;

%### Ziegler_nichols Frequencial

%temperatura

Kp_t = 2.9268;
Ki_t = 0.0232;
Kd_t = 92.1942;





g0_t = Kp_t + ((Ki_t*T_amostra)/2) + (Kd_t/T_amostra);

g1_t = ((Ki_t*T_amostra)/2) - Kp_t - ((2*Kd_t)/T_amostra);

g2_t = Kd_t/T_amostra;



%umidade

Ku_u=.4975;

Tu_u=108; %em segundos. Equivale à 1.8 min

%

Kp_u=0.6*Ku_u

Ti_u=0.5*Tu_u;

Td_u=0.125*Tu_u;



% %M?toro Trapezoidal

Ki_u = Kp_u/Ti_u

Kd_u = Kp_u*Td_u



% Kp_u = .5;
% 
% Ki_u = 0.0055;
% 
% Kd_u = 4.0419;


disp(Kp_u);
disp(Ki_u);
disp(Kd_u);
g0_u = Kp_u + ((Ki_u*T_amostra)/2) + (Kd_u/T_amostra);

g1_u = ((Ki_u*T_amostra)/2) - Kp_u - ((2*Kd_u)/T_amostra);

g2_u = Kd_u/T_amostra;

%Loop de Controle

%Calculos dos parametros do controlador PID





% Loop de controle

for k = 8:qtde_amostras

    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);

    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * u_2u(k-3) - 0.01718 * u_2u(k-4);

    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * u_1t(k-6) - 0.007485 * u_1t(k-7);

    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);



    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;

    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;



    erro1(k) = r_1t(k) - y_1t(k);

    erro2(k) = r_2u(k) - y_2u(k);

    u_1t(k) = u_1t(k-1) + g0_t * erro1(k) + g1_t * erro1(k-1) + g2_t * erro1(k-2);

    u_2u(k) = u_2u(k-1) + g0_u * erro2(k) + g1_u * erro2(k-1) + g2_u * erro2(k-2);


    if u_1t(k) > 100

        u_1t(k) = 100;

    end

    if u_1t(k) < 0

        u_1t(k) = 0;

    end

    %-------------------

    if u_2u(k) > 100

        u_2u(k) = 100;

    end

    if u_2u(k) < 0

        u_2u(k) = 0;

    end

    tempo(k) = k * T_amostra;

end





%% PLOTAGEM DE GRÁFICOS

% Subplot para r_1, y_1 e u_1

figure(2);

subplot(2,2,1)

hold on

plot(tempo/60, r_1t, 'b', 'LineWidth', 1);

plot(tempo/60, y_1t, 'r', 'LineWidth', 1.5);hold off

ylabel('Temperatura(°C)');

xlabel('Tempo(min)');

title('Referência de Temperatura - r_{1}(k)');
ylim([0 100]);

% legend('r_1(k)', 'y_1(k)');

grid on



subplot(2,2,2)

plot(tempo/60, u_1t, 'g', 'LineWidth', 1.5);

xlabel('Tempo(min)');

ylabel('Temperatura(°C)');

title('Sinal de Controle - u_{1}');

grid on





subplot(2,2,3)

hold on

plot(tempo/60, r_2u, 'b', 'LineWidth', 1);

plot(tempo/60, y_2u, 'r', 'LineWidth', 1.5);hold off

ylabel('Umidade(%)');

xlabel('Tempo(min)');

title('Referência de Umidade - r_{2u}(k)');
ylim([0 100]);
% legend('r_1(k)', 'y_1(k)')
grid on



subplot(2,2,4)

plot(tempo/60, u_2u, 'g', 'LineWidth', 1.5);

xlabel('Tempo(min)')

ylabel('Umidade(%)')

title('Sinal de Controle - u_{2u}')

grid on