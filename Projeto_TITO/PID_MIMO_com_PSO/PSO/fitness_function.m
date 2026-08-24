% =========================================================================
% Função: Função Objetivo (Custo/Aptidão)
% Objetivo: Simular o controle de uma planta e retornar o erro acumulado.
% A partícula aqui é um vetor [Kp, Ti, Td] (Parâmetros do Controlador PID).
% =========================================================================

function aptidao = fitness_function(part, plotar, n_pop, max_it, g, i, salvar)
    
    % --- Tratamento de Argumentos de Entrada ---
    % Se a função for chamada sem os parâmetros extras, define valores padrão
    if nargin < 1
        % Se você rodar o arquivo direto, ele usa valores de teste
        part = [1.0, 10.0, 0.5]; 
    end
    
    if (nargin < 2), plotar = false; end % Evita abrir 400 janelas sem querer
    if (nargin < 7), salvar = false; end
    if (nargin < 5), g = 1; i = 1; n_pop = 1; max_it = 1; end

    % --- Parâmetros da Simulação ---
    t_run = 3000;  % Tempo total da simulação (segundos)
    Ts = 18;       % Tempo de amostragem (taxa de atualização do sistema)

    % --- Extração de Parâmetros da Partícula (PID) ---
    % A partícula do PSO contém as constantes do controlador
    Kp = part(1); % Ganho Proporcional
    Ti = part(2); % Tempo Integral
    Td = part(3); % Tempo Derivativo
    
    % Conversão para ganhos Ki e Kd
    Ki = Kp/Ti; 
    Kd = Kp*Td;

    % --- Constantes da Equação de Diferença (PID Digital) ---
    % Transforma o PID contínuo para a forma discreta (usada em computadores)
    c1 = Kp + Kd/Ts;
    c2 = -Kp - 2*(Kd/Ts) + Ki*Ts;
    c3 = Kd/Ts;

    % --- Inicialização de Vetores de Estado ---
    % Inicializa saídas (y), controle (u), referência (r) e erro (e) com zeros
    y(1:5) = 22; u(1:5) = 0; e(1:5) = 0;
    % Remova a pré-alocação fixa r(1:200) = 30;
    
    t(1) = 0; t(2) = Ts; t(3) = 2*Ts; t(4) = 3*Ts; t(5) = 4*Ts; % Corrigi a sequência aqui (3*Ts estava faltando)
    r(1:5) = 30; % Inicializa a referência para acompanhar os índices iniciais
    n = 5;
% Aplicação do relé							
   
    % --- Loop de Simulação (Dinâmica do Sistema) ---
    while t(n) <= t_run
        n = n + 1;
        t(n) = (n-1)*Ts; % Atualiza o relógio da simulação
        r(n) = 30;        % Setpoint (valor que queremos que o sistema alcance)
    
        % EQUAÇÃO DA PLANTA (O sistema que você está controlando)

        % y(n) é a saída atual baseada na saída anterior e na ação de controle atrasada
        %y(n) = 0.9441*y(n-1) + 0.03184*u(n-3);

        %equacao a diferenças da temperatura desacoplada
        y(n) = 0.9678 * y(n-1) + 0.08796 * u(n-4) + 0.00509 * u(n-5);
        % Cálculo do erro (O quanto estamos longe do objetivo)
        e(n) = r(n) - y(n);
    
        % EQUAÇÃO DO CONTROLADOR PID (Ação de Controle)
        % u(n) é o sinal enviado para o atuador (ex: abertura de válvula, tensão)
        u(n) = u(n-1) + c1*e(n) + c2*e(n-1) + c3*e(n-2);
    
        % Saturação do Atuador (Limites Físicos)
        % Garante que o comando não exceda o limite ( 0 a 100 ℃)
        if u(n) > 100
            u(n) = 100;
        elseif u(n) < 0
            u(n) = 0;
        end
    end

    % --- Visualização ---
    if plotar == true 
        k = g + i; % Calcula a posição no subplot
        subplot(n_pop, max_it, k);
        plot(t, r, 'r--', t, y, 'b'); % Plota referência (tracejado) e saída
        grid on;
    end
   
    % --- Cálculo do Custo (Aptidão) ---
    % Aqui usamos o IAE (Integral of Absolute Error)
    % Quanto menor o IAE, melhor o controlador conseguiu seguir a referência.
    aptidao = 0;
    for j = 1: length(e)
        %aptidao = aptidao + abs(e(j));
        aptidao = aptidao + (j * abs(e(j))); % Soma o erro absoluto ponderado pelo tempo% No final da função fitness, antes de retornar a aptidao:
%disp(['Partícula: ', num2str(part), ' -> Custo: ', num2str(aptidao)]);
    end
    
    % --- Outros Critérios (Comentados) ---
    % ITEA: Dá mais peso a erros que demoram a sumir (penaliza demora em estabilizar)
    % IEQ: Erro quadrático (penaliza erros grandes de forma agressiva)

    % --- Salvar Dados em Arquivo ---
    if salvar == true 
        mat = [t', r', u', e', y']; % Organiza os dados em colunas
        indice = string(i);         % Identificador da partícula
        cabecalho = ["t", "r", "u", "e" , "y"] + indice;
        SalvarDados(mat, cabecalho, g, i); % Chama função externa para salvar
    end
end