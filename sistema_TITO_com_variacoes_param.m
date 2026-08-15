% --SCRIPT - SISTEMA TITO  VARIAÇÕES PARAMÉTRICAS --
clear; clc; close all;

%% 1. CONFIGURAÇÕES GERAIS
qtde_amostras = 600;
T_amost = 18; 
k_acoplamento = 0.1;
% Cenários - Variacoes de 2%, 5% e 10%(para mais ou para menos)
%_____P_min__|__P_max____
% 2% | 0.98  |  1.02
% 5% | 0.95  |  1.05
% 10%| 0.9   |  1.1
cenarios_pmax = [1.02, 1.05, 1.1]; 
cenarios_pmin = [0.98, 0.95, 0.9]; 

cores = {'r', 'g', 'b'};       

figure(1); 

for idx = 1:length(cenarios_pmax)
    p = cenarios_pmax(idx);
    
    %% 2. MODELAGEM E DISCRETIZAÇÃO
    Gs_11 = tf([2.89*p], [550*p 1], 'InputDelay', 55*p);
    Gs_12 = tf([-3.1*k_acoplamento*p], [260*p 1], 'InputDelay', 51*p);
    Gs_21 = tf([-4.22*p], [546*p 1], 'InputDelay', 91*p);
    Gs_22 = tf([22.22*k_acoplamento*p], [180*p 1], 'InputDelay', 16*p);

    Gz_11 = c2d(Gs_11, T_amost, 'zoh')
    Gz_12 = c2d(Gs_12, T_amost, 'zoh')
    Gz_21 = c2d(Gs_21, T_amost, 'zoh')
    Gz_22 = c2d(Gs_22, T_amost, 'zoh')
end
for idx = 1:length(cenarios_pmin)
    p = cenarios_pmin(idx);
    
    %% 2. MODELAGEM E DISCRETIZAÇÃO
    Gs_11 = tf([2.89*p], [550*p 1], 'InputDelay', 55*p);
    Gs_12 = tf([-3.1*k_acoplamento*p], [260*p 1], 'InputDelay', 51*p);
    Gs_21 = tf([-4.22*p], [546*p 1], 'InputDelay', 91*p);
    Gs_22 = tf([22.22*k_acoplamento*p], [180*p 1], 'InputDelay', 16*p);

    Gz_11 = c2d(Gs_11, T_amost, 'zoh')
    Gz_12 = c2d(Gs_12, T_amost, 'zoh')
    Gz_21 = c2d(Gs_21, T_amost, 'zoh')
    Gz_22 = c2d(Gs_22, T_amost, 'zoh')
end

%     %% 5. PLOTAGEM
%     subplot(1,2,1); hold on;
%     plot(tempo/60, y_1mft, 'Color', cores{idx}, 'LineWidth', 1, 'DisplayName', ['p = ' num2str(p)]);
%     if idx == 1, plot(tempo/60, r_1t, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Ref'); end
% 
%     subplot(1,2,2); hold on;
%     plot(tempo/60, y_2mfu, 'Color', cores{idx}, 'LineWidth', 1, 'DisplayName', ['p = ' num2str(p)]);
%     if idx == 1, plot(tempo/60, r_2u, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Ref'); end
% end
% 
% subplot(1,2,1); grid on; ylabel('Temp (°C)'); title('Robustez - Temperatura'); legend('show','Location','best');
% subplot(1,2,2); grid on; ylabel('Umidade (%)'); xlabel('Tempo (min)'); title('Robustez - Umidade'); legend('show','Location','best');