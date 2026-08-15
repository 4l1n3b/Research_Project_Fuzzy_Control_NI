% Código para Implementar PID ZN - UMIDADE (Corrigido, mantendo a estrutura original)
clear;

% Determinação do período de amostragem
T_amostra = 18;  

% ##### Parâmetros do Processo para Ziegler Nichols (Método de Malha Aberta)
Kcr = 5.350;
Pcr = 1.8*60;
Kp=0.6*Kcr
Ti=0.5*Pcr
Td=0.125*Pcr

Kp=2.8
 Ki=Kp/Ti
Kd=Kp*Td

g0=Kp*(1+(Td/T_amostra)+(T_amostra/Ti));
g1=-Kp*(1+2*(Td/T_amostra));
g2=Kp*Td/T_amostra;


% ##### Configurações da Simulação
qtde_amostras = 600;
u_2u = zeros(1, qtde_amostras);
erro = zeros(1, qtde_amostras);
y_22u = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);
r_2u(1:qtde_amostras) = 50; % Referência de 50
r_2u(qtde_amostras/3+1:2*qtde_amostras/3) = 60; 
r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55; 


for k=1:2
   y_22u(k) = 50; 
   erro(k)=r_2u(k) - y_22u(k); 
   tempo(k) = k*T_amostra;
end
%Fecha a malha 
for k=3:qtde_amostras
      y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
      erro(k)=r_2u(k)-y_22u(k);
      u_2u(k)= u_2u(k-1) + g0*erro(k) + g1*erro(k-1) + g2*erro(k-2);
      if u_2u(k) > 100
          u_2u(k) = 100;
      end
      if u_2u(k) < 0
          u_2u(k) = 0;
      end
      tempo(k)=k*T_amostra;
end 

% ##### Geração dos Gráficos
figure(4)
subplot(2,1,1)
plot(tempo/60, r_2u, 'b', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_22u, 'r', 'LineWidth', 1);
legend('Referência', 'Saída do Sistema');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
title('Resposta do Sistema com Controle PID (ZN)');
grid on;
hold off;

subplot(2,1,2)
hold on;
plot(tempo/60, u_2u, 'g', 'LineWidth', 1);
legend('Sinal de Controle (%)');
xlabel('Tempo (min)');
ylabel('Valor');
title('Sinal de controle do Controle PID');
grid on;
hold off;

%==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_2u(:), y_22u(:), u_2u(:), erro(:), ...
%     'VariableNames', {'Tempo', 'Referencia_Umidade', 'Saida_Umidade', 'Sinal_Controle_Umidade', 'Erro_Umidade'});
% 
% filename = 'planilhas/dados_PID_2ZN_SISO_umidade.csv';
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
% r_2u = T_lida.Referencia_Umidade;
% y_22u = T_lida.Saida_Umidade;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro = T_lida.Erro_Umidade;