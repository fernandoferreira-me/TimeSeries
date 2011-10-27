function [xte]=tendencia_exponencial(coef,amostras,snr);
%coef: coeficiente coef*i/amostras
%amostras
%relacao sinal ruido

for i=1:amostras
    xte(i)=exp(coef*(i/(amostras)))+(randn(1)*snr);
end