function [residuo] = hetero(serie,c)
%Aplica a função exponencial na série para retirar a heterocedasticidade
%crescimeto: modelo de crescimento da variancia. Ex.: 'linear'
[n1,n2]=size(serie);

t=c*((1:n2)/n2);%Crescimento linear da variancia ajustado por uma constante definida na modelagem
residuo=serie./exp(t);
end

