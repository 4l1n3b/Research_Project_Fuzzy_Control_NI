% Controlador
close all;
clear all;
clc;

% Primeiro passo: Definir o universo de discurso
% Vamos dividir em 10000 pontos
qs = linspace(0, 10, 1000); 
qc = linspace(0, 10, 1000); 
g  = linspace(0, 25, 1000);

% Segundo passo: Gerar as funções de pertinência para cada input
qs_muito_ruim   = trapezoidal(qs, 0, 0, 2, 4);
qs_razoavel   = triangular(qs, 0, 5, 10);
qs_muito_bom    = trapezoidal(qs, 6, 8, 10, 10);

qc_muito_ruim = trapezoidal(qc, 0, 0, 2, 4);
qc_razoavel   = triangular(qc, 1, 5, 7);
qc_muito_boa  = trapezoidal(qc, 6, 8, 10, 10);

g_peq   = trapezoidal(g, 0, 0, 10, 10);
g_razoavel = trapezoidal(g, 10, 10, 15, 15);
g_grande = trapezoidal(g, 15, 15, 20, 20);

%entrada dos valores 
% Terceiro passo: Obter os valores singleton dos valores de amostra
prompt = 'Qual a qualidade de serviço?\n\n';
qsa = input(prompt);
while (qsa > 10 || qsa < 0)
    display('Valor inválido.');
    qsa = input(prompt);
end

prompt = 'Qual a qualidade de comida?\n\n';
qca = input(prompt);
while (qca > 10 || qca < 0)
    display('Valor inválido.');
    qca = input(prompt);
end

% Agora os singletons
s1 = singleton(qs, qs_muito_ruim, qsa);
s2 = singleton(qs, qs_razoavel, qsa);
s3 = singleton(qs, qs_muito_bom, qsa);

s4 = singleton(qc, qc_muito_ruim, qca);
s5 = singleton(qc, qc_razoavel, qca);
s6 = singleton(qc, qc_muito_boa, qca);

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
out1 = saida(g_peq, r1);
out2 = saida(g_peq, r2);
out3 = saida(g_razoavel, r3);
out4 = saida(g_peq, r4);
out5 = saida(g_razoavel, r5);
out6 = saida(g_razoavel, r6);
out7 = saida(g_razoavel, r7);
out8 = saida(g_grande, r8);
out9 = saida(g_grande, r9);

% Sexto passo: Agregação
agreg = max([out1; out2; out3; out4; out5; out6; out7; out8; out9]);

% Sétimo passo: Usar centro de área para obter valor da pressão no freio
g_saida = centro_area(g, agreg);

% Mostrar resultado
display(sprintf('O valor da gorjeta é: %.2f', g_saida));

% Gráficos
figure;
plot(qs, qs_muito_ruim, qs, qs_razoavel, qs, qs_muito_bom, 'LineWidth', 3);
legend('qs_muito_ruim', 'qs_razoavel', 'qs_muito_bom');
title('Entrada: Qualidade de Serviço');
xlabel('Qualidade de Serviço');
%ylabel('\mu_v');
axis([0 10 0 1]);
grid on;

figure;
plot(qc, qc_muito_ruim, qc, qc_razoavel, qc, qc_muito_boa, 'LineWidth', 3);
legend('qc_muito_ruim', 'qc_razoavel', 'qc_muito_boa');
title('Entrada: Qualidade de Comida');
xlabel('Qualidade de Comida');
%ylabel('\mu_m');
axis([0 10 0 1]);
grid on;

figure;
plot(g, [out1; out2; out3; out4; out5; out6; out7; out8; out9], 'LineWidth', 3);
legend('out1', 'out2', 'out3', 'out4', 'out5', 'out6', 'out7', 'out8', 'out9');
title('Saída: Gorgeta para cada regra');
xlabel('Gorgeta');
%ylabel('\mu_p');
axis([0 20 0 1]);
grid on;

figure;
plot(g, agreg, 'LineWidth', 3);
title('Saída: Gorgeta');
xlabel('Gorgeta');
%ylabel('\mu_p');
axis([0 20 0 10]);
grid on;