% Controlador
close all;
clear all;
clc;

% Primeiro passo: Definir o universo de discurso
% Vamos dividir em 10000 pontos
v = linspace(0, 180, 10000);
m = linspace(0, 2.4, 10000);
p = linspace(0, 20, 10000);

% Segundo passo: Gerar as funções de pertinência para cada input
vbaixa   = trapezoidal(v, 0, 0, 50, 100);
vmedia   = triangular(v, 50, 125, 150);
valta    = trapezoidal(v, 100, 150, 180, 180);

mpequena = trapezoidal(m, 0, 0, 0.5, 1);
mmedia   = triangular(m, 0.5, 1.25, 1.5);
mgrande  = trapezoidal(m, 1.25, 2, 2.4, 2.4);

pfraca   = trapezoidal(p, 0, 0, 5, 15);
pelevada = trapezoidal(p, 5, 15, 20, 20);
%entrada dos valores 
% Terceiro passo: Obter os valores singleton dos valores de amostra
prompt = 'Qual o valor da velocidade do carro nesse momento?\n\n';
va = input(prompt);
while (va > 180 || va < 0)
    display('Valor inválido.');
    va = input(prompt);
end

prompt = 'Qual o valor da massa do carro nesse momento?\n\n';
ma = input(prompt);
while (ma > 2.4 || ma < 0)
    display('Valor inválido.');
    ma = input(prompt);
end

% Agora os singletons
s1 = singleton(v, vbaixa, va);
s2 = singleton(v, vmedia, va);
s3 = singleton(v, valta, va);

s4 = singleton(m, mpequena, ma);
s5 = singleton(m, mmedia, ma);
s6 = singleton(m, mgrande, ma);

% Quarto passo: Usar o conectivo das regras
r1 = min(s1, s4);
r2 = min(s1, s5);
r3 = min(s1, s6);
r4 = min(s2, s4);
r5 = min(s2, s5);
r6 = min(s2, s6);
r7 = min(s3, s4);
r8 = min(s3, s5);
r9 = min(s3, s6);

% Quinto passo: Usar a implicação de Mamdani
out1 = saida(pfraca, r1);
out2 = saida(pfraca, r2);
out3 = saida(pelevada, r3);
out4 = saida(pfraca, r4);
out5 = saida(pelevada, r5);
out6 = saida(pelevada, r6);
out7 = saida(pelevada, r7);
out8 = saida(pelevada, r8);
out9 = saida(pelevada, r9);

% Sexto passo: Agregação
agreg = max([out1; out2; out3; out4; out5; out6; out7; out8; out9]);

% Sétimo passo: Usar centro de área para obter valor da pressão no freio
psaida = centro_area(p, agreg);

% Mostrar resultado
display(sprintf('O valor da pressão no freio é: %.2f', psaida));

% Gráficos
figure;
plot(v, vbaixa, v, vmedia, v, valta, 'LineWidth', 3);
legend('vbaixa', 'vmedia', 'valta');
title('Entrada: Velocidade');
xlabel('V [km/h]');
ylabel('\mu_v');
axis([0 180 0 1]);
grid on;

figure;
plot(m, mpequena, m, mmedia, m, mgrande, 'LineWidth', 3);
legend('mpequena', 'mmedia', 'mgrande');
title('Entrada: Massa');
xlabel('M [ton]');
ylabel('\mu_m');
axis([0 2.4 0 1]);
grid on;

figure;
plot(p, [out1; out2; out3; out4; out5; out6; out7; out8; out9], 'LineWidth', 3);
legend('out1', 'out2', 'out3', 'out4', 'out5', 'out6', 'out7', 'out8', 'out9');
title('Saída: Pressão cada regra');
xlabel('P [bar]');
ylabel('\mu_p');
axis([0 20 0 1]);
grid on;

figure;
plot(p, agreg, 'LineWidth', 3);
title('Saída: Pressão');
xlabel('P [bar]');
ylabel('\mu_p');
axis([0 20 0 1]);
grid on;