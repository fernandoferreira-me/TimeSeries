function [y,x0] = difsaz(x,n)
%Função que extrai a sazonalidade de periodo n
%x: série 
%n: período da sazonalidade

for k=n+1:length(x),
    y(k-n)=x(k)-x(k-n);
end
x0=x(1:n);%amostras iniciais para recuperar a série sem sazonalidade