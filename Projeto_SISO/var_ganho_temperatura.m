% Código para Implementar PID ZN - UMIDADE (Corrigido, mantendo a estrutura original)
clear;

% Determinação do período de amostragem
T_amostra = 18;  


% ##### Configurações da Simulação
qtde_amostras = 1000;
u_1t = zeros(1, qtde_amostras);
erro = zeros(1, qtde_amostras);
y_11t = zeros(1, qtde_amostras);
tempo = zeros(1, qtde_amostras);
r_1t(1:qtde_amostras) = 30; % Referência de 50
% r_2u(qtde_amostras/3+1:2*qtde_amostras/3) = 60; 
% r_2u(2*qtde_amostras/3+1:qtde_amostras) = 55; 


for k=1:5
   %u_2u(k) = 24.82;%valor adicionado apos calculo feito(pag. 80-81 - Caderno de pesquisa)  
   y_11t(k) = 22; 
   erro(k)=r_1t(k) - y_11t(k); 
   tempo(k) = k*T_amostra;
end
ganho_prop = 4.876 ;
%Fecha a malha 
for k=6:qtde_amostras
    y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
      erro(k)=r_1t(k)-y_11t(k);
      u_1t(k)= ganho_prop*erro(k);
      % if u_1t(k) > 100
      %     u_1t(k) = 100;
      % end
      % if u_1t(k) < 0
      %     u_1t(k) = 0;
      % end
      tempo(k)=k*T_amostra;
end 

% ##### Geração dos Gráficos
figure(4)
% subplot(2,1,1)
plot(tempo/60, r_1t, 'b', 'LineWidth', 1.5); hold on;
plot(tempo/60, y_11t, 'r', 'LineWidth', 1);
legend('Referência', 'Saída do Sistema');
xlabel('Tempo (min)');
ylabel('Temperatura (°C)');
title('Resposta do Sistema com Controle PID (ZN)');
grid on;
hold off;

% subplot(2,1,2)
% hold on;
% plot(tempo/60, u_1t, 'g', 'LineWidth', 1);
% legend('Sinal de Controle (%)');
% xlabel('Tempo (min)');
% ylabel('Valor');
% title('Sinal de controle do Controle PID');
% grid on;
% hold off;

%==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_2u(:), y_22u(:), u_2u(:), erro(:), ...
%     'VariableNames', {'Tempo', 'Referencia_Umidade', 'Saida_Umidade', 'Sinal_Controle_Umidade', 'Erro_Umidade'});
% 
% filename = 'planilhas/dados_PID_ZN_SISO_umidade.csv';
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