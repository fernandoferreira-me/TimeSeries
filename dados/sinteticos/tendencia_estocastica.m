function [ xest ] = tendencia_estocastica(xinicial, ruidote,amostras)
%Sintetiza a tendência estocástica
x(1)=xinicial;
for i=1:amostras
    x(i+1)=x(i)+x(1)+ruidote*randn(1);
end
xest=x(1:amostras);

end

