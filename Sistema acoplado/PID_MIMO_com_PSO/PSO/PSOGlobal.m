% =========================================================================
% Algoritmo: Particle Swarm Optimization (PSO) Global Corrigido
% Objetivo: Encontrar o mínimo global de uma função matemática.
% =========================================================================
function [melhor, pos, todos_melhores] = PSOGlobal(dim, n_pop, lim_v, lim_p, max_it, AC1, AC2)
    
    % --- Parâmetros de Inércia ---
    w = 1;            % Fator de inércia (estabilidade)
    wdamp = 1;       % Amortecimento da inércia (opcional, para refinar a busca)

    % --- Inicialização ---
    % Inicializa posições dentro dos limites [min max] de cada dimensão
    enxame = zeros(n_pop, dim + 1);
    enxame(:, 1:dim) = lim_p(:,1)' + (lim_p(:,2)' - lim_p(:,1)') .* rand(n_pop, dim);
    
    % Inicializa velocidades dentro dos limites
    vel_enxame = lim_v(:,1)' + (lim_v(:,2)' - lim_v(:,1)') .* rand(n_pop, dim);
    
    % Estruturas para histórico
    melhores_enxame = zeros(n_pop, dim + 1);    % pBest
    todos_melhores = zeros(max_it, 1);          % Histórico gBest
    
    % Calcula a aptidão inicial para definir o gBest
    [melhor, pos_melhor, enxame] = aptidao_inicial(enxame, n_pop, dim);
    melhores_enxame = enxame; 
    
    % --- Loop Principal (Evolução) ---
    for it = 1:max_it
        
        % 1. Atualiza a Velocidade (Passando o w atual)
        vel_enxame = velocidade(enxame, melhores_enxame, lim_v, vel_enxame, pos_melhor, n_pop, dim, AC1, AC2, w);
        
        % 2. Atualiza a Posição
        enxame = posicao(enxame, vel_enxame, n_pop, dim, lim_p);
        
        % 3. Avaliação de Aptidão e Atualização de Recordes
        [melhor, pos_melhor, enxame, melhores_enxame] = aptidao(enxame, melhores_enxame, melhor, pos_melhor, n_pop, dim);
        
        % Atualiza a inércia para a próxima iteração (Damping)
        w = w * wdamp;
        
        % Armazena dados de convergência
        todos_melhores(it) = melhor;
        
        fprintf('Iteração %d: Melhor Custo = %f\n', it, melhor);

        % --- NOVO: Visualização 3D em tempo real ---
        if dim >= 3
            figure(2); % Abre uma segunda janela para as partículas
            scatter3(enxame(:,1), enxame(:,2), enxame(:,3), 30, enxame(:, dim+1), 'filled');
            hold on;
            % Destaca o melhor global (gBest) com um 'X' vermelho
            plot3(melhores_enxame(pos_melhor,1), melhores_enxame(pos_melhor,2), melhores_enxame(pos_melhor,3), ...
                  'rx', 'MarkerSize', 15, 'LineWidth', 2);
            hold off;
            
            title(['Posição das Partículas - Iteração: ', num2str(it)]);
            xlabel('Eixo X'); ylabel('Eixo Y'); zlabel('Eixo Z');
            grid on;
            colorbar; % Mostra a escala de cores baseada no custo (fitness)
            view(45, 30); % Ajusta o ângulo de visão
            drawnow;      % Força o MATLAB a desenhar o gráfico imediatamente
        end
    end
    
    % Resultado final
    pos = melhores_enxame(pos_melhor, 1:dim);
    
    % Visualização
    figure();
    plot(todos_melhores, 'LineWidth', 1.5);
    title('Curva de Convergência do PSO');
    xlabel('Iteração');
    ylabel('Melhor Aptidão (Custo)');
    grid on;
end

% --- Subfunção: Avaliação Inicial ---
function [melhor, pos_melhor, enxame] = aptidao_inicial(enxame, n_pop, dim)
    % Avalia a primeira partícula
    melhor = fitness_function(enxame(1, 1:dim), false); 
    pos_melhor = 1; 
    enxame(1, dim + 1) = melhor;
    
    for i = 2:n_pop
        apt = fitness_function(enxame(i, 1:dim), false);
        enxame(i, dim + 1) = apt;
        if (apt < melhor) 
            melhor = apt;
            pos_melhor = i;
        end
    end
end

% --- Subfunção: Avaliação e Atualização de Recordes ---
function [melhor, pos_melhor, enxame, melhores_enxame] = aptidao(enxame, melhores_enxame, melhor, pos_melhor, n_pop, dim)
    for i = 1:n_pop
       % Calcula o custo da nova posição
       enxame(i, dim + 1) = fitness_function(enxame(i, 1:dim), false);
       
       % Atualiza pBest (Recorde Pessoal)
       if (enxame(i, dim + 1) < melhores_enxame(i, dim + 1))
           melhores_enxame(i, :) = enxame(i, :);
            
           % Atualiza gBest (Recorde Global)
           if(melhores_enxame(i, dim + 1) < melhor)
                melhor = melhores_enxame(i, dim + 1);
                pos_melhor = i;
           end
       end
    end
end

% --- Subfunção: Cálculo da Velocidade ---
function [vel_enxame] = velocidade(enxame, melhores_enxame, lim_v, vel_enxame, pos_melhor, n_pop, dim, AC1, AC2, w)
    for i = 1:n_pop
        % r1 e r2 devem ser vetores para cada dimensão para melhor exploração
        r1 = rand(1, dim); 
        r2 = rand(1, dim); 
        
        % Equação com Inércia (w): v(t+1) = w*v(t) + AC1*r1*(pBest-x) + AC2*r2*(gBest-x)
        vel_enxame(i, :) = w * vel_enxame(i, :) + ...
                           AC1 * r1 .* (melhores_enxame(i, 1:dim) - enxame(i, 1:dim)) + ...
                           AC2 * r2 .* (melhores_enxame(pos_melhor, 1:dim) - enxame(i, 1:dim));
        
        % Controle de fronteira da velocidade (Vetorizado)
        vel_enxame(i, :) = max(min(vel_enxame(i, :), lim_v(:,2)'), lim_v(:,1)');
    end
end

% --- Subfunção: Atualização de Posição ---
function enxame = posicao(enxame, vel_enxame, n_pop, dim, lim_p)
    for i = 1:n_pop
        % Atualiza posição
        enxame(i, 1:dim) = enxame(i, 1:dim) + vel_enxame(i, :);
        
        % Controle de fronteira da posição (Vetorizado)
        % Garante que cada variável respeite seu próprio limite
        enxame(i, 1:dim) = max(min(enxame(i, 1:dim), lim_p(:,2)'), lim_p(:,1)');
    end
end