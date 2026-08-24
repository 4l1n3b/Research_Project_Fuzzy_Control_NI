% --- Função de Transferência Discreta G(z) ---
num = [0.2455 1.869];
den = [1 -0.9048 0];
G = tf(num, den, T_amostra);

% --- Plot do Diagrama de Nyquist ---
figure(7);
nyquist(G);
grid on;
title('Diagrama de Nyquist do Processo G(z)');