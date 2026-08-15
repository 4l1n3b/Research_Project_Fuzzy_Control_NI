%{
    funcao que procura a entrada no universo de discurso e aproxima
    linearmente atraves da média do valor de pertinencia
    -Variáveis
    x: vetor universo de discurso
    y: MP relativa a x
    a: entrada
%}
function s = singleton(x,y,a)
    n = find(x>=a,1,'first');
    if isempty(n)
        s = y(end);
    elseif n == 1
        s = y(1);
    else
        s = 0.5*(y(n)+y(n-1));
    end
end
