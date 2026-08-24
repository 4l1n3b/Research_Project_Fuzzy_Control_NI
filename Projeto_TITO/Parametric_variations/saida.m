%{
    Ceifar funcao de pertinencia
    -Variáveis
    s: valor onde a MP deve ser ceifada
    y: MP 
%}
function y = saida(mf, s)
    y = mf;
    y(y > s) = s;
end

