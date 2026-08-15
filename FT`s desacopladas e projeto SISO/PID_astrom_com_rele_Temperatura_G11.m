varlist = {'ref','u','e','y', 'tempo','ch'};
clear(varlist{:})
clear; clc; close all;
T_amostra = 18; %periodo de amostragem
qtde_amostras = 600;
%---------------------------------------
%Método do Relé
%---------------------------------------

%Especificação dos parâmetros do relé 
d = 16;
eps = 2;
u_1t = zeros(1,qtde_amostras);
erro1 = zeros(1,qtde_amostras); 
y_11t = zeros(1,qtde_amostras);
tempo = zeros(1,qtde_amostras);
r_1t(1:qtde_amostras) = 22;
for k=1:5
   u_1t(k) = 22 - d;
   y_11t(k) = 22;
   erro1(k) = r_1t(k) - y_11t(k);
   tempo(k) = k*T_amostra;
end

% Aplicação do relé
for k = 6:qtde_amostras								
   y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
   erro1(k) = r_1t(k) - y_11t(k);
   if ((abs(erro1(k)) >= eps) && (erro1(k)  >0))      
       u_1t(k) = 22+ d;
   end
   if ((abs(erro1(k)) > eps) && (erro1(k) < 0))      
       u_1t(k) = 22-d; 
   end
   if ((abs(erro1(k)) < eps) && (u_1t(k-1) == 22+d))  
       u_1t(k) = 22+d; 
   end
   if ((abs(erro1(k)) < eps) && (u_1t(k-1) == 22-d))  
       u_1t(k) = 22-d; 
   end
   tempo(k) = k*T_amostra;
end


% Saída do relé
clf(figure(4))
figure(4)
% subplot(2,1,1)
hold on
plot(tempo, r_1t,'r', 'LineWidth', 1.5);
ylabel('Temperatura (°C)');
xlabel('Tempo(s)');
title('Referência de Temperatura - r_{1t}');
grid on
hold off
% subplot(2,1,2)
clf(figure(6))
figure(6)
hold on
plot(tempo, u_1t,'b',tempo, y_11t,'g', 'LineWidth', 1.5);
legend('Saída do Relé - u_{1t}','Saída de Temperatura - y_{1t}','Location','southeast','FontSize',9);
ylabel('Temperatura (°C)');
xlabel('Tempo(s)');
title('Oscilação Induzida pelo Relé')
grid on
hold off
%------------------------------------------------------------------------
%% Sintonia de Controladores PID pelo Método de Astrom
%------------------------------------------------------------------------

%inicialização de parametros
a = 5.2004;
Tu = 882;
omega = (2*pi)/(Tu);

Kp=0;
Ki=0;
Kd=0;

%Calculo de ganho e fase do processo com os parametros do relé(Ponto A)
Gw_real=-(pi*sqrt(a^2-eps^2))/(4*d)
Gw_imag=-(pi*eps)/(4*d)
r_a=abs(Gw_real-j*Gw_imag) 
phi_a=atan(eps/sqrt(a^2-eps^2))

% Especifica~çoes de ganho e fase(Ponto B)
%O valor de r_b é dado em funcao de r_a, a medida que aumenta-se o valor da
%ponteracao sobre r_a, o processo responde mas rápido, mas cada vez com
%mais oscilações até que a curva no diagrama de Nyquist passe do ponto -1
%levando, desse modo, o sistema à instabilidade. De modo analogo, á medida
%que se reduz a ponderação, o sistema torna-se mais lento, mas com menos
%oscilações no transitorio.
phi_b=40;
r_b=1*r_a;
phi_b=pi*phi_b/180; %phi_b em radianos

%Calculo dos paramteros do controlador(Ponto B) 
Kp=r_b*cos(phi_b-phi_a)/r_a     
aux1=tan(phi_b-phi_a);
aux2=sqrt(1+aux1^2);
aux3=aux1+aux2;
Ti=aux3/(2*omega*0.25)
Td=0.25*Ti

Kp=Kp
Ki=Kp/Ti
Kd=Kp*Td

% Execucao do algoritmo que implementa um PID digital

%Discretizaçõa pelo método trapezoidal
g0=Kp*(1+(Td/T_amostra)+(T_amostra/Ti));
g1=-Kp*(1+2*(Td/T_amostra));
g2=Kp*Td/T_amostra;

%Inicialização da referencia para implementacao de um degrau unitario
% Qtd_amostra=1000; 
% for k=1:Qtd_amostra, r(k)=1;  end ;
%inicializaçaõ da referencia de acordo com os patamares
 qtde_amostras=600; 
r_1t(1:qtde_amostras / 3) = 30;
r_1t(qtde_amostras /3+1:2*qtde_amostras/3) = 36;
r_1t(2*qtde_amostras/3+1:qtde_amostras) = 33;

for k=1:5
   y_11t(k) = 22; 
   u_1t(k) = 0;
   erro1(k)= r_1t(k) - y_11t(k); 
   tempo(k) = k*T_amostra;
end
%Fecha a malha 
for k=6:qtde_amostras
      y_11t(k) = 0.9678 * y_11t(k-1) + 0.08796 * u_1t(k-4) + 0.00509 * u_1t(k-5);
      
      erro1(k)=r_1t(k)-y_11t(k);
      u_1t(k)= u_1t(k-1) + g0*erro1(k) + g1*erro1(k-1) + g2*erro1(k-2);

      %tratamento do sina;l de controle
      if u_1t(k) > 100
          u_1t(k) = 100;
      end
      if u_1t(k) < 0
          u_1t(k) = 0;
      end
      tempo(k)=k*T_amostra;

end 

% % Garantir que os vetores têm o mesmo comprimento antes de plotar
% N = min([length(tempo), length(r_1t), length(u_1t), length(y_11t)]);
% 
% tempo = tempo(1:N);
% r_1t = r_1t(1:N);
% u_1t = u_1t(1:N);
% y_11t = y_11t(1:N);

clf(figure(5))
% clf(figure(6))
figure(5)
% %Plotar gráfico
% hold on
% plot(tempo, r, 'b', tempo, y_11t, 'r', 'LineWidth', .1);
% title('Sinais de Saída e de Referência PID Astrom')
% xlabel('Tempo  (s)') 
% ylabel('r,  y') 
% legend('Referência r(k)', 'Saída y(k)')
% grid on
% hold off
% figure(6)
% hold on
% plot(tempo, u_1t, 'g','LineWidth', 1);
% title('Sinal de Controle PID Astrom')
% xlabel('Tempo  (s)') 
% ylabel('u(k)') 
% legend('Sinal de Controle u(k)')
% grid on
% hold off
% Primeiro subplot – Saída y_1
subplot(2,1,1) 
hold on
plot(tempo/60, r_1t,'r', 'LineWidth', 1.5)
plot(tempo/60,  y_11t,'b', 'LineWidth', 1)
ylabel('Temperatura (°C)');
xlabel('Tempo(min)');
title('Referência e Saída de Temperatura- r_{1t} e y_{11t}');
legend('Referência de Temperatura', 'Saída de Temperatura')
ylim([0 60])
hold off

%------------
subplot(2,1,2) 
hold on
% plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
plot(tempo/60, u_1t, 'g', 'LineWidth', 1.5)
% plot(tempo/60, y_1mft,'m', 'LineWidth', 1)
% plot(tempo/60, erro1,'b', 'LineWidth', 1)
% legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MF}');%, 'Erro 1 - e_{1MF}');
% title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
ylabel('Temperatura (°C)');
xlabel('Tempo(min)');
title('Sinal de Controle - u_{1t}');
hold off
%-------------------
% subplot(2,1,3) 
% hold on
% % plot(tempo/60, u_1t,'r--', 'LineWidth', 1)
% % plot(tempo/60, u_2u, 'g', 'LineWidth', 1.5)
% plot(tempo/60, y_11t,'m', 'LineWidth', 1.5)
% % plot(tempo/60, erro1,'b', 'LineWidth', 1)
% % legend('Entrada 1 - u_{1}', 'Entrada 2 - u_{2}','Saída 1 - y_{1MF}');%, 'Erro 1 - e_{1MF}');
% % title('Resposta da Saída 1 em Malha Fechada - y_{1MF}')
% ylabel('y_{11}(°C)');
% xlabel('Tempo(min)');
% title('Saída de Temperatura - y_{1t}');
% 
% hold off
% ==== SALVAR DADOS EM PLANILHA ====
% T = table(tempo(:), r_1t(:), y_11t(:), u_1t(:), erro1(:), ...
%     'VariableNames', {'Tempo','Referencia_Temperatura', 'Saida_Temperatura', 'Sinal_Controle_Temperatura', 'Erro_Temperatura'});
% 
% filename = 'planilhas/dados_PID_astrom_SISO_temperatura.csv';
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
% erro1 = T_lida.Erro_Temperatura;
%% teste de insercao de eros de fase nao minima pelo controlador
coeficientes_num = [g0, g1, g2];
zeros_controlador = roots(coeficientes_num);

% 3. Verificar a magnitude
magnitudes_zeros = abs(zeros_controlador);

disp('--- Análise dos Zeros do Controlador PID ---');
disp(['Kp = ' num2str(Kp, 4) ', Ti = ' num2str(Ti, 4) ', Td = ' num2str(Td, 4)]);
disp(['g0 = ' num2str(g0, 4) ', g1 = ' num2str(g1, 4) ', g2 = ' num2str(g2, 4)]);
disp('Zeros do Controlador (z1, z2):');
disp(zeros_controlador);
disp('Magnitudes dos Zeros:');
disp(magnitudes_zeros);

% 4. Conclusão da Fase
if all(magnitudes_zeros < 1)
    disp('Conclusão: O controlador PID é de FASE MÍNIMA (todos os |z| < 1).');
else
    disp('Conclusão: O controlador PID possui ZEROS NÃO MÍNIMOS (pelo menos um |z| > 1).');
end
disp('-------------------------------------------');