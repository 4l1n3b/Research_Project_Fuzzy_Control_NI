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
        if(n<=1) s = y(n);
        else s = (y(n)+y(n-1))*0.5;
        end
end
