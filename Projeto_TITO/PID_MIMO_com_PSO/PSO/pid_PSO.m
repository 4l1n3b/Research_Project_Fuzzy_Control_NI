% PID SISO Sintonizado por PSO

T_amostra = 18;  %Determina??o do per?odo de amostragem



%% PARAMETROS CALCULADOR PELO PSO
Kp = 2.7150;
Ti = 200.9739;
Td =  22.5631;

%% DISCRETIZAÇÃO DOS GANHOS DO CONTROLADOR PELO MÉTODO TRAPEZOIDAL
g0=Kp*(1+(Td/T_amostra)+(T_amostra/Ti));
g1=-Kp*(1+2*(Td/T_amostra));
g2=Kp*Td/T_amostra;

%% INICIALIZAÇÃO DE VALORES
qtde_amostras=600;

u_1t = zeros(1,qtde_amostras);
erro = zeros(1,qtde_amostras);
y_11t = zeros(1,qtde_amostras);
tempo = zeros(1,qtde_amostras);

r_1t(1:qtde_amostras) = 30;
r_1t(qtde_amostras /3+1:2*qtde_amostras/3) = 36;
r_1t(2*qtde_amostras/3+1:qtde_amostras) = 33;

for k=1:5
    y_11t(k) = 22;
    %u_1t(k) = 7.61; %valor adicionado apos calculo feito(pag. 79 - Caderno de pesquisa)
    erro(k)= r_1t(k) - y_11t(k);
    de(k) = 0;
    d2e(k) = 0;
    tempo(k) = k*T_amostra;
end

%% MALHA DE CONTROLE
for k=6:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
    erro(k)=r_1t(k)- y_11t(k);
    u_1t(k)= u_1t(k-1) + g0*erro(k)+ g1*erro(k-1) + g2*erro(k-2);

    if u_1t(k)>100
        u_1t(k)=100;
    end
    if u_1t(k)<0
        u_1t(k)=0;
    end
    
    tempo(k) = k*T_amostra;
end
for k=6:qtde_amostras
    de(k) = erro(k) - erro(k-1);
    d2e(k) = de(k) - de(k-1);
end
% % ==== SALVAR DADOS EM PLANILHA ====
% % Agrupar dados em uma tabela
%  tau = table(Tempo(:), r(:), y(:), u(:), erro(:), ...
%  'VariableNames', {'Tempo', 'Referencia', 'Saida', 'Controle', 'Erro'});
%  % Salvar em arquivo Excel
%  filename = 'dados_PID_1Met_ZN_fis.csv';
%  writetable(tau, filename);
% %
%  disp('dados_PID_1Met_ZN_fis.csv');
%
%
% % ==== LER DADOS DA PLANILHA ====
% % Ler o arquivo Excel
% T_lida = readtable('dados_PID_1Met_ZN_est.csv');
%
% % Atribuir colunas às variáveis
%  Tempo = T_lida.Tempo;
%  r = T_lida.Referencia;
%  y = T_lida.Saida;
%  u = T_lida.Controle;
%  erro = T_lida.Erro;

% Exibir os primeiros valores
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
figure(4)
subplot(2,1,1)
plot(tempo/60, r_1t, 'b', 'LineWidth', 1.5); hold on;   % Referência - azul
plot(tempo/60, y_11t, 'r', 'LineWidth', 1);            % Saída - vermelho
legend('Referência de Temperatura - r_{1t}', 'Saída do Sistema - y_{11t}');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
title('Resposta do Sistema com Controle PID através do 1 método de ZN');
grid on;
hold off;
subplot(2,1,2)
hold on;
plot(tempo/60, u_1t, 'g', 'LineWidth', 1);            % Controle - verde
legend('Sinal de Controle (°C)');
xlabel('Tempo (min)');
ylabel('Valor');
title('Sinal de controle do Controle PID através do 1 método de ZN');
grid on;
hold off;

% ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), y_11t(:), u_1t(:), erro(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Saida_Temperatura', 'Sinal_Controle_Temperatura', 'Erro_Temperatura'});
% 
% filename = 'planilhas/dados_PID_ZN_SISO_temperatura.csv';
% writetable(T, filename);
% disp(['Dados salvos em: ' filename]);
% 
% % ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
% 
% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_1t = T_lida.Referencia_Temperatura;
% y_11t = T_lida.Saida_Temperatura;
% u_1t = T_lida.Sinal_Controle_Temperatura;
% erro = T_lida.Erro_Temperatura;