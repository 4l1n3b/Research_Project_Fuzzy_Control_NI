% --SCRIPT - IMPLEMENTAR PATAMARES EM SISTEMA TITO com Variacoes Paramétricas--
clear; clc; %close all;
qtde_amostras = 600;
T_amost = 18; % Tempo de amostragem em segundos

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
    r_2u(k) = 50;
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
r_2u(8:qtde_amostras/3) = 50; 
r_2u((qtde_amostras/3+1):(2*qtde_amostras/3)) = 50;
r_2u((2*qtde_amostras/3+1):qtde_amostras) = 55;

%% LOOPS PARA SIMULAÇÃO
% Matrix of coefficients from every  transfer function of the transfer
% matrix
y_11 = [0.9684 0.08237 0.01071; 0.9693 0.07396 0.01916; 0.9707 0.05986 0.03333; ...
0.9672 0.0005254 0.09249; 0.9661 0.00918 0.08379; 0.9643 0.02354 0.06934];
y_12 = [0.9344 -0.002352 -0.01840; 0.9362  -0.0005361 -0.02023; 0.9390 -0.01844 -0.00236; ...
    0.9318 -0.004755 -0.01597; 0.9297 -0.006544 -0.01415;0.926 -0.009492 -0.01116];
y_21 = [0.9682 -0.1157 -0.02116; 0.9691 -0.09519  -0.04177; 0.9705 -0.06066 -0.07640;...
    0.9669 -0.006333 -0.1305; 0.9659 -0.02734 -0.1094; 0.964 -0.06209 -0.07451];
y_22 = [0.9066 0.02064 0.1910; 0.9092 0.01477 0.1972; 0.9131 0.004933 0.2075;...
    0.9030 0.02845  0.1828; 0.9001 0.03428 0.1766; 0.8948 0.04395 0.1664];
%Variação - 1.02,1.05, 1.1
for i = 1: 3
    for k = 8:qtde_amostras
        % As equações de diferenças precisam ter acesso aos valores anteriores.
        % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
        % em cada passo, partindo de zero.
        y_11t(k) = y_11(i,1)* y_11t(k-1) + y_11(i,2)* erro1(k-4) + y_11(i,3) * erro1(k-5);
        y_12u(k) = y_12(i,1) * y_12u(k-1) + y_12(i,2) * erro2(k-3) + y_12(i,3) * erro2(k-4);
        y_21t(k) = y_21(i,1) * y_21t(k-1) + y_21(i,2) * erro1(k-6) + y_21(i,3) * erro1(k-7);
        y_22u(k) = y_22(i,1) * y_22u(k-1) + y_22(i,2) * erro2(k-1) + y_22(i,3) * erro2(k-2);
        
        % As saídas do sistema são a soma das parcelas calculadas
        y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
        y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
        
        % Cálculo do erro para a próxima iteração
        erro1(k) = r_1t(k) - y_1t(k);
        erro2(k) = r_2u(k) - y_2u(k);
        
        tempo(k) = k * T_amost;
    end

    % ==== SALVAR DADOS EM PLANILHA ====
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
    if i == 1
        filename = 'Tables/incubadora_var_param102.csv';
    elseif i == 2
        filename = 'Tables/incubadora_var_param105.csv';
    elseif i == 3
        filename = 'Tables/incubadora_var_param110.csv';
    end
    writetable(T, filename);
end

%Variação - 1.02,0.95, 0.9
for i = 4: 6
    for k = 7:qtde_amostras
        % As equações de diferenças precisam ter acesso aos valores anteriores.
        % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
        % em cada passo, partindo de zero.
        y_11t(k) = y_11(i,1)* y_11t(k-1) + y_11(i,2)* erro1(k-3) + y_11(i,3) * erro1(k-4);
        y_12u(k) = y_12(i,1) * y_12u(k-1) + y_12(i,2) * erro2(k-3) + y_12(i,3) * erro2(k-4);
        y_21t(k) = y_21(i,1) * y_21t(k-1) + y_21(i,2) * erro1(k-5) + y_21(i,3) * erro1(k-6);
        y_22u(k) = y_22(i,1) * y_22u(k-1) + y_22(i,2) * erro2(k-1) + y_22(i,3) * erro2(k-2);
        
        % As saídas do sistema são a soma das parcelas calculadas
        y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
        y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
        
        % Cálculo do erro para a próxima iteração
        erro1(k) = r_1t(k) - y_1t(k);
        erro2(k) = r_2u(k) - y_2u(k);
        
        tempo(k) = k * T_amost;
    end

    % ==== SALVAR DADOS EM PLANILHA ====
    T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
        'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
    if i == 4
        filename = 'Tables/incubadora_var_param98.csv';
    elseif i == 5
        filename = 'Tables/incubadora_var_param95.csv';
    elseif i == 6
        filename = 'Tables/incubadora_var_param90.csv';
    end
    writetable(T, filename);
end
% %1.02
% for k = 8:qtde_amostras
%     % As equações de diferenças precisam ter acesso aos valores anteriores.
%     % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
%     % em cada passo, partindo de zero.
%     y_11t(k) = 0.9684 * y_11t(k-1) + 0.08237 * erro1(k-4) + 0.01071 * erro1(k-5);
%     y_12u(k) = 0.9344 * y_12u(k-1) - 0.002352 * erro2(k-3) - 0.01840 * erro2(k-4);
%     y_21t(k) = 0.9682 * y_21t(k-1) - 0.1157 * erro1(k-6) - 0.02116 * erro1(k-7);
%     y_22u(k) = 0.9066 * y_22u(k-1) + 0.02064 * erro2(k-1) + 0.1910 * erro2(k-2);
% 
%     % As saídas do sistema são a soma das parcelas calculadas
%     y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
%     y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
% 
%     % Cálculo do erro para a próxima iteração
%     erro1(k) = r_1t(k) - y_1t(k);
%     erro2(k) = r_2u(k) - y_2u(k);
% 
%     tempo(k) = k * T_amost;
% end
% % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'Tables/incubadora_var_param102.csv';
% writetable(T, filename);
% 
% % =====================================
% %1.05
% for k = 8:qtde_amostras
%     % As equações de diferenças precisam ter acesso aos valores anteriores.
%     % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
%     % em cada passo, partindo de zero.
%     y_11t(k) = 0.9693 * y_11t(k-1) + 0.07396 * erro1(k-4) + 0.01916 * erro1(k-5);
%     y_12u(k) = 0.9362 * y_12u(k-1) - 0.0005361 * erro2(k-3) - 0.02023 * erro2(k-4);
%     y_21t(k) = 0.9691 * y_21t(k-1) - 0.09519 * erro1(k-6) - 0.04177 * erro1(k-7);
%     y_22u(k) = 0.9092 * y_22u(k-1) + 0.01477 * erro2(k-1) + 0.1972 * erro2(k-2);
% 
%     % As saídas do sistema são a soma das parcelas calculadas
%     y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
%     y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
% 
%     % Cálculo do erro para a próxima iteração
%     erro1(k) = r_1t(k) - y_1t(k);
%     erro2(k) = r_2u(k) - y_2u(k);
% 
%     tempo(k) = k * T_amost;
% end
% % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'Tables/incubadora_var_param105.csv';
% writetable(T, filename);
% 
% % =====================================
% %1.10
% for k = 8:qtde_amostras
%     % As equações de diferenças precisam ter acesso aos valores anteriores.
%     % Como só conhecemos a CI da saída total, as parciais devem ser calculadas
%     % em cada passo, partindo de zero.
%     y_11t(k) = 0.9707 * y_11t(k-1) + 0.05986 * erro1(k-4) + 0.03333 * erro1(k-5);
%     y_12u(k) = 0.9390 * y_12u(k-1) - 0.01844 * erro2(k-3) - 0.00236 * erro2(k-4);
%     y_21t(k) = 0.9705 * y_21t(k-1) - 0.06066 * erro1(k-6) - 0.07640 * erro1(k-7);
%     y_22u(k) = 0.9131 * y_22u(k-1) + 0.004933 * erro2(k-1) + 0.2075 * erro2(k-2);
% 
%     % As saídas do sistema são a soma das parcelas calculadas
%     y_1t(k) = y_11t(k) + y_12u(k) + y_1mft_inicial;
%     y_2u(k) = y_21t(k) + y_22u(k) + y_2mfu_inicial;
% 
%     % Cálculo do erro para a próxima iteração
%     erro1(k) = r_1t(k) - y_1t(k);
%     erro2(k) = r_2u(k) - y_2u(k);
% 
%     tempo(k) = k * T_amost;
% end
% % ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), r_2u(:), y_1t(:), y_2u(:), erro1(:), erro2(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Referencia_Umidade','Saida_Temperatura', 'Saida_Umidade','Erro_Temperatura', 'Erro_Umidade'});
% 
% filename = 'Tables/incubadora_var_param110.csv';
% writetable(T, filename);
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);
% 
% % ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));

% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_1t = T_lida.Referencia_Temperatura;
% r_2u = T_lida.Referencia_Umidade;
% y_1t = T_lida.Saida_Temperatura;
% y_2u = T_lida.Saida_Umidade;
% u_1t = T_lida.Sinal_Controle_Temperatura;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro1 = T_lida.Erro_Temperatura;
% erro2 = T_lida.Erro_Umidade;

%% PLOTAGEM DE GRÁFICOS
% MALHA FECHADA

% figure(2)
% subplot(2,2,1) 
% hold on
% plot(tempo/60, r_1t,'black', 'LineWidth', 1.5)
% plot(tempo/60, y_1t,'r', 'LineWidth', 1)
% ylabel('Temperatura (°C)');
% xlabel('Tempo(min)');
% title('Referência de Temperatura e Saída de Temperatura');
% legend('Referência de Temperatura - r_{1t}', 'Saída de Temperatura - y_{1t}')
% grid on
% hold off
% 
% subplot(2,2,2) 
% hold on
% plot(tempo/60, r_2u, 'black', 'LineWidth', 1.5)
% plot(tempo/60, y_2u,'b', 'LineWidth', 1)
% ylabel('Umidade Relativa (%)');
% xlabel('Tempo(min)');
% title('Referência de Umidade e Saída de Umidade');
% legend('Referência de Umidade - r_{2u}', 'Saída de Umidade - y_{2u}')
% grid on
% hold off
% 
% subplot(2,2,3) 
% hold on
% plot(tempo/60, erro1, 'g', 'LineWidth', 1)
% ylabel('Temperatura (°C)');
% xlabel('Tempo(min)');
% title('Erro de Temperatura - e_{1t}');
% grid on
% hold off
% 
% subplot(2,2,4)
% hold on
% 
% plot(tempo/60, erro2, 'm', 'LineWidth', 1)
% title('Erro de Umidade - e_{2u}')
% ylabel('Umidade Relativa (%)');
% xlabel('Tempo(min)');
% grid on
% hold off

