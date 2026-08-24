%==========================================================================
% CONTROLADOR PID (2º MÉTODO DE ZIEGLER-NICHOLS) - TEMPERATURA DESACOPLADA
%==========================================================================
clear; clc;

%% PARÂMETROS DA SIMULAÇÃO E DISCRETIZAÇÃO
qde_amostras = 900;
T_amostra = 18; % Período de amostragem em segundos

% Ganho estático (Temperatura desacoplada)
k22v = [20.923; 21.339];

% Constante de tempo
tau22v = [170.196; 177.685];

% Atraso de transporte (s) e em amostras
Td22v = [16; 15];
am_Td22 = [1, 1];


% Pré-alocação dos modelos discretos
num_mat = cell(2, 1);
den_mat = cell(2, 1);

for idx = 1:2
    Gs_22 = tf([k22v(idx)], [tau22v(idx) 1], 'InputDelay', Td22v(idx));
    Gz_22 = c2d(Gs_22, T_amostra, 'zoh');
    [num_mat{idx,1}, den_mat{idx,1}] = tfdata(Gz_22, 'v');
end


% ##### Parâmetros do Processo para Ziegler Nichols (Método de Malha Aberta)
Kcr = .535;
Pcr = (1.5)*60;
Kp=0.6*Kcr
Ti=0.5*Pcr
Td=0.125*Pcr

%Kp=.28;
 Ki=Kp/Ti
Kd=Kp*Td

g0=Kp*(1+(Td/T_amostra)+(T_amostra/Ti));
g1=-Kp*(1+2*(Td/T_amostra));
g2=Kp*Td/T_amostra;

%% CONFIGURAÇÃO DA SIMULAÇÃO E MODELO
i = 3; % Seleção da variação paramétrica: 1, 2 ou 3

amostras = [300, 600, 900];
r_2u   = zeros(1, qde_amostras);
y_2u   = zeros(1, qde_amostras);
y_22u  = zeros(1, qde_amostras);
u_2u   = zeros(1, qde_amostras);
erro   = zeros(1, qde_amostras);

r_2u(1:amostras(1))  = 55; % Referência de 50
r_2u((amostras(1)+1):amostras(2)) = 60; 
r_2u((amostras(2)+1):amostras(3))= 50; 

tempo = (0:qde_amostras-1) * T_amostra;
y_2u_inicial = 50;

% Condição inicial e ponteiro de amostragem
if i ~= 3
    n22 = num_mat{i,1}; d22 = den_mat{i,1};
    cont = am_Td22(i) + 2;
else
    cont = 3;
end
soma_erro = 0;
% Inicialização das condições de contorno
for k = 1:(cont-1)
    y_2u(k) = y_2u_inicial;
    erro(k) = r_2u(k) - y_2u(k);
    soma_erro = abs(erro(k)) + soma_erro;
    u_2u(k) = 0;
end

%Fecha a malha 
for k=cont:qde_amostras
      if i == 3
            y_22u(k) = 0.9048 * y_22u(k-1) + 0.2455 * u_2u(k-1) + 1.869 * u_2u(k-2);
      else
            y_22u(k) = -d22(2)*y_22u(k-1) + n22(1)*u_2u(k-am_Td22(i)) + n22(2)*u_2u(k-am_Td22(i)-1);
      end

      % saida com a temperatura inicial
      y_2u(k) = y_22u(k) + y_2u_inicial;

      %Calculo do erro
      erro(k)=r_2u(k)-y_2u(k);
       soma_erro = abs(erro(k)) + soma_erro;
      % Calculo do sinal de controle
      u_2u(k)= u_2u(k-1) + g0*erro(k) + g1*erro(k-1) + g2*erro(k-2);

      % Saturação do Sinal de Controle [0, 100]%  - Limitacao do atuador
      if u_2u(k) > 100
          u_2u(k) = 100;
      elseif u_2u(k) < 0
          u_2u(k) = 0;
      end
      
end 
soma_erro

%% SALVAMENTO DOS DADOS EM TABELA CSV
% T = table(tempo(:), r_2u(:), y_2u(:), u_2u(:), erro(:), ...
%     'VariableNames', {'Tempo', 'Referencia_Umidade', 'Saida_Umidade', 'Controle_Umidade', 'Erro_Umidade'});
% 
% switch i
%     case 1
%         filename = 'Tables/incubadora_var_param1PID_Umid.csv';
%     case 2
%         filename = 'Tables/incubadora_var_param2PID_Umid.csv';
%     otherwise
%         filename = 'Tables/incubadora_var_param100PID_Umid.csv';
% end
% 
% if ~exist('Tables', 'dir'), mkdir('Tables'); end
% writetable(T, filename);
% disp(['Dados PID salvos com sucesso em: ' filename]);

%% PLOTAGEM DOS RESULTADOS
figure(4); clf;
subplot(2, 1, 1);
plot(tempo/60, r_2u, 'r--', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_2u, 'b', 'LineWidth', 2);
title('Saída de Umidade'); xlabel('Tempo (min)'); ylabel('Umidade Relativa (%)');
legend('Referência', 'Saída'); grid on;

subplot(2, 1, 2);
plot(tempo/60, u_2u, 'g', 'LineWidth', 2);
title('Sinal de Controle (u)'); xlabel('Tempo (min)'); ylabel('Sinal de Controle (%)');
grid on;
% 
% % ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));

% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_2u = T_lida.Referencia_Umidade;
% y_22u = T_lida.Saida_Umidade;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro = T_lida.Erro_Umidade;