function [serie_rec] = heteroinv(residuo,c)
%Aplica a função exponencial inversa na série
%crescimeto: modelo de crescimento da variancia. Ex.: crescimento=[1:T]/T
[n1,n2]=size(residuo);
t=c*((1:n2)/n2);%Crescimento linear da variancia ajustado por uma constante definida na modelagem
serie_rec=residuo.*exp(t);
end

