function r = random_alt(intervalo, linhas, colunas)
    % Esta função intercepta o randi original.
    % Ela permite velocidades negativas e limites decimais.
    
    % Organizamos os limites para garantir que o menor venha sempre primeiro
    v_min = min(intervalo); 
    v_max = max(intervalo);
    
    % Gera números decimais (contínuos) entre o mínimo e o máximo
    % Isso permite que a partícula se mova para trás e para frente com precisão
    r = v_min + (v_max - v_min) .* rand(linhas, colunas);
end