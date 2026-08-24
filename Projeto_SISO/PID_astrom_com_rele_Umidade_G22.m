  %% Método do Relé - Umidade

varlist = {'ref','u','e','y', 'tempo','ch'};
clear(varlist{:})
clear; clc; close all;
T_amostra = 18; %periodo de amostragem
qtde_amostras = 100;
%---------------------------------------
%Método do Relé
%---------------------------------------

%Especificação dos parâmetros do relé 
d = 35;
eps = 1;
u_2u = zeros(1,qtde_amostras);
erro2 = zeros(1,qtde_amostras); 
y_22u = zeros(1,qtde_amostras);
tempo = zeros(1,qtde_amostras);
r_2u(1:qtde_amostras) = 50;
for k=1:3
   u_2u(k) = 50-d;
   y_22u(k) = 50;
   erro2(k) = r_2u(k) - y_22u(k);
   tempo(k) = k*T_amostra;
end

% Aplicação do relé
for k = 3:qtde_amostras								
  y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
   erro2(k) = r_2u(k)-y_22u(k);
   if ((abs(erro2(k)) >= eps) && (erro2(k)  >0))      u_2u(k) = 50 + d; end;
   if ((abs(erro2(k)) > eps) && (erro2(k) < 0))      u_2u(k) = 50 - d; end;
   if ((abs(erro2(k)) < eps) && (u_2u(k-1) == 50 + d))   u_2u(k) = 50 + d; end;
   if ((abs(erro2(k)) < eps) && (u_2u(k-1) == 50 - d))  u_2u(k) = 50 - d; end;
   tempo(k) = k*T_amostra;
end

% % Cálculo do período
%  kont = 0;								
%  for k = 3:Qtd_amostra,								
%     if u_2u(k) ~= u_2u(k-1)
%        kont = kont + 1;
%        ch(kont) = k;
%     end
%  end
%  Tu1 = (ch(3) - ch(2))*T_amostra;
% Tu2 = (ch(4) - ch(3))*T_amostra;
%  Tu = Tu1 + Tu2
%  omega = (2*pi)/(Tu)
% 
%  % Cálculo da amplitude da senoide(a)
%  amp_max = eps;										
%  for k = 3:Qtd_amostra,
%     if y_22u(k) >= amp_max  amp_max = y_22u(k); end;
%  end;
%  a = amp_max

% Saída do relé
clf(figure(4))
figure(4)
% subplot(2,1,1)
hold on
plot(tempo, r_2u,'r', 'LineWidth', 1.5);
ylabel('Temperatura (°C)');
xlabel('Tempo(s)');
title('Referência de Temperatura - r_{1t}');
grid on
hold off
% subplot(2,1,2)
clf(figure(6))
figure(6)
hold on
plot(tempo, u_2u,'b',tempo, y_22u,'r', 'LineWidth', 1.5);
legend('Saída do Relé - u_{2u}','Saída de Umidade - y_{2u}','Location','southeast','FontSize',9);
ylabel('Umidade Relativa (%)');
xlabel('Tempo(s)');
title('Oscilação Induzida pelo Relé')
grid on
hold off

%------------------------------------------------------------------------
%% Sintonia de Controladores PID pelo Método de Astrom
%------------------------------------------------------------------------
a = 11.3978;
Tu = 216;
omega = (2*pi)/(Tu);
%inicialização de parametros
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
phi_b=50;
r_b=1.5*r_a;
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
 Qtd_amostra=600; 
 for k=1:Qtd_amostra/3, r_2u(k)=50;  end ;
 for k=Qtd_amostra/3+1:2*Qtd_amostra/3, r_2u(k)=60;  end ;
 for k=2*Qtd_amostra/3+1:Qtd_amostra, r_2u(k)=55;  end ;

for k=1:3
   u_2u(k) = 0;
   y_22u(k) = 50; 
   erro2(k)=r_2u(k) - y_22u(k); 
   tempo(k) = k*T_amostra;
end

%Fecha a malha 
for k=3:Qtd_amostra
      y_22u(k) = 0.9048 * y_22u(k-1) + 0.02455 * u_2u(k-1) + 0.1869 * u_2u(k-2);
      % y_22u(k) = y_22u(k) + 60;
      erro2(k)=r_2u(k)-y_22u(k);
      u_2u(k)= u_2u(k-1) + g0*erro2(k) + g1*erro2(k-1) + g2*erro2(k-2);
      if u_2u(k) > 100
          u_2u(k) = 100;
      end
      if u_2u(k) < 0
          u_2u(k) = 0;
      end
      tempo(k)=k*T_amostra;
end 

clf(figure(5))
% clf(figure(6))
figure(5)

subplot(2,1,1) 
hold on
plot(tempo/60, r_2u,'r', 'LineWidth', 1)
plot(tempo/60,  y_22u,'b', 'LineWidth', 1)
ylabel('Umidade Relativa (%)');
xlabel('Tempo(min)');
title('Referência e Saída de Umidade- r_{2u} e y_{22u}');
legend('Referência de Umidade', 'Saída de Umidade')

hold off
%------------
subplot(2,1,2) 
hold on
plot(tempo/60, u_2u, 'g', 'LineWidth', 1)
ylabel('Umidade (%)');
xlabel('Tempo(min)');
title('Sinal de Controle - u_{2u}')
%ylim([10 50])
hold off


%-------------------

% ==== SALVAR DADOS EM PLANILHA ====
T = table(tempo(:), r_2u(:), y_22u(:), u_2u(:), erro2(:), ...
    'VariableNames', {'Tempo', 'Referencia_Umidade', 'Saida_Umidade', 'Sinal_Controle_Umidade', 'Erro_Umidade'});

filename = 'planilhas/dados_PID_astrom_SISO_umidade.csv';
writetable(T, filename);
disp(['Dados salvos em: ' filename]);

% % ==== LER DADOS DA PLANILHA ====
% T_lida = readtable(filename);
% 
% disp('Primeiras linhas dos dados lidos:');
% disp(head(T_lida));
% 
% % Se quiser usar as variáveis separadas:
% Tempo = T_lida.Tempo;
% r_2u = T_lida.Referencia_Umidade;
% y_22u = T_lida.Saida_Umidade;
% u_2u = T_lida.Sinal_Controle_Umidade;
% erro2 = T_lida.Erro_Umidade;

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