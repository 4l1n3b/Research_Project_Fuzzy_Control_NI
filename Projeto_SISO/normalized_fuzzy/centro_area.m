%{
    Centro de Área(Centroid)
    -Variáveis
    x: vetor universo de discurso
    y: MP agregada 
%}
function cm = centro_area(x,y)
cm = sum(x.*y)/sum(y);
end