function [xt]=tendencia_linear(coef,b,amostras,snr);
%coef: coeficiente da reta
%b: bias
%amostras
%relacao sinal ruido

for i=1:amostras
    ruido(i)=(randn(1)*snr);
end

for i=1:amostras
    xt(i)=coef*i+b;
end
desvio=std(ruido);

xt=xt+ruido;


%[rsn] = sinal_ruido(xt,ruido);