
function y = triangular( x , a , b , c )
for k = 1 : length( x )
    if x(k)<=a
        y(k) = 0;
    elseif (x(k) > a && x(k) <= b)
        y(k) = (x(k) - a) / ( b - a ) ;
    elseif (x(k) > b && x(k) <= c)
        y(k) =(c - x(k))/(c - b) ;
    else
        y(k)=0;
    end
end
end

