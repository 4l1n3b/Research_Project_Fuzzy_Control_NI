function y = trapezoidal( x , a , b , c , d )
for k = 1 : length( x )
    if x(k)<=a
        y(k) =0;
    elseif (x(k) > a && x(k) <= b)
        y(k) = (x(k) - a) / ( b - a ) ;
    elseif (x(k) > b && x(k) <= c)
        y(k) = 1 ;
    elseif (x(k) > c && x(k) <= d)
        y(k) =(d - x(k))/(d - c) ;
    else
        y(k)=0;
    end
end
end
