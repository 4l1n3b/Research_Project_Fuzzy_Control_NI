% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO --
clear; clc; %close all;
qtde_amostras = 900;
T_amost = 18;

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
v_1 = zeros(1,qtde_amostras);
v_2 = zeros(1,qtde_amostras);

% --- DEFINIÇÃO DAS CONDIÇÕES INICIAIS DA SAÍDA TOTAL ---
% O autor do código original define os 7 primeiros pontos para r e y
y_1t_inicial = 22; % Condição inicial da saída de temperatura
y_2u_inicial = 50; % Condição inicial da saída de umidade

% Os primeiros 7 pontos de tempo devem ser configurados com a referência
% e a saída inicial.
for k = 1:7 
    r_1t(k) = 30;
    r_2u(k) = 50;
    y_1t(k) = y_1t_inicial;
    y_2u(k) = y_2u_inicial;
    erro1(k) = r_1t(k) - y_1t(k);
    erro2(k) = r_2u(k) - y_2u(k);
    tempo(k) = (k) * T_amost;
    % Variáveis de controle do desacoplador inicializadas
    v_1(k) = 0; 
    v_2(k) = 0;
end

%% DEFININDO OS PATAMARES DE CADA ENTRADA
% Entrada 1 - Temperatura
r_1t(8:qtde_amostras/3) = 30; 
r_1t((qtde_amostras/3+1):(2*qtde_amostras/3)) = 36; 
r_1t((2*qtde_amostras/3+1):qtde_amostras) = 36;
% Entrada 2 - Umidade
r_2u(8:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):(qtde_amostras)) = 55;

%% INCLUSÃO DO DESACOPLADOR ESTÁTICO
% Parâmetros do desacoplador (extraídos das F.T. originais)
K11 = 2.89;
K12 = -0.31; % k = 0.1
K21 = -4.22;
K22 = 2.222; % k = 0.1

% Matriz de desacoplamento estático M
% M = [1, -K12/K11; -K21/K22, 1];
% Termos da matriz para cálculo
D_12 = -K12 / K11;
D_21 = -K21 / K22;

%% LOOPS PARA MALHA ABERTA E FECHADA
% (Mantenha o loop de malha aberta como está, ele é para referência)

% MALHA FECHADA COM DESACOPLADOR
% Note que estamos usando os erros diretamente, sem controlador PID ainda.
for k = 8:qtde_amostras
    % 1. Calcula o erro
    erro1(k) = r_1t(k) - y_1t(k-1);
    erro2(k) = r_2u(k) - y_2u(k-1);
    
    % 2. Aplica o desacoplador estático nos erros
    % As novas variáveis de controle v1 e v2 são calculadas a partir dos erros
    v_1(k) = erro1(k) + D_12 * erro2(k);
    v_2(k) = D_21 * erro1(k) + erro2(k);
    
    % 3. Insere as novas variáveis de controle (v) no sistema, no lugar do erro.
    % As equações de diferença agora usam v_1 e v_2
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * v_1(k-4) + 0.00509 * v_1(k-5);
    y_12u(k) = 0.9331 * y_12u(k-1) - 0.003556 * v_2(k-3) - 0.01718 * v_2(k-4);
    
    y_21t(k) = 0.9676 * y_21t(k-1) - 0.1294 * v_1(k-6) - 0.007485 * v_1(k-7);
    y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * v_2(k-1) + 0.1869 * v_2(k-2);
    
    % 4. Calcula as saídas
    y_1t(k) = y_11t(k) + y_12u(k) + y_1t_inicial;
    y_2u(k) = y_21t(k) + y_22u(k) + y_2u_inicial;
    
    tempo(k) = k * T_amost;
end

%% PLOTAGEM DE GRÁFICOS

%MALHA FECHADA 
figure(1)

% Primeiro subplot – Saída y_1
subplot(2,2,1) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1.5)
% plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
% plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
% plot(tempo/60, erro1,'b', 'LineWidth', 1)
% legend('Entrada 1 - u_{1}');%, 'Erro 1 - e_{1MF}');
% title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
ylabel('r_{1}(°C)');
xlabel('Tempo(min)');
text((310*T_amost/60),33,'\leftarrowr_{1t}');
hold off

%------------
subplot(2,2,2) 
hold on
% plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, r_2u, 'g', 'LineWidth', 1.5)
% plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
% plot(tempo/60, erro1,'b', 'LineWidth', 1)
% legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MF}');%, 'Erro 1 - e_{1MF}');
% title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
ylabel('r_{2}(%)');
xlabel('Tempo(min)');
text((610*T_amost/60),53,'\leftarrowr_{2u}');
hold off
%-------------------
subplot(2,2,3) 
hold on
% plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
% plot(tempo/60, u_2u, 'g', 'LineWidth', 1.5)
plot(tempo/60, y_1t,'m', 'LineWidth', 1.5)
% plot(tempo/60, erro1,'b', 'LineWidth', 1)
% legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MF}');%, 'Erro 1 - e_{1MF}');
% title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
ylabel('y_{1}(°C)');
xlabel('Tempo(min)');
text((410*T_amost/60),23.5,{' \uparrow ', ' y_{1t}'});
hold off
% Segundo subplot – Saída y_2
subplot(2,2,4)
hold on
% plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
% plot(tempo/60, u_2u, 'g:', 'LineWidth', 1.5)
plot(tempo/60, y_2u,'b', 'LineWidth', 1)
%plot(tempo/60, erro2,'b', 'LineWidth', 1)
% legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 2 - y_{2MF}');%,'Erro 2 - e_{2MF}');
% title('Resposta da Saída 2 em Malha Fechada - y_{2MF}')
text((120*T_amost/60),26.3,{' y_{2u}',' \downarrow '});
ylabel('y_{2}(%)');
xlabel('Tempo(min)');
hold off
