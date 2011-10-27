function yint = intsaz(x,n,x0)
% Inverte a diferenciação sazonal
%x: resíduo
%n: período de sazonalidade
%x0: amostras iniciais
%Saída
%yint: série recuperada

for k=1:n,
    serie(k).dados=cumsum([x0(k) x(k:n:length(x))]);
end

cont=1;
while cont<length(x)+n+1,
    linha=rem(cont,n);if linha==0 linha=n; end;
    yint(cont)=serie(linha).dados(ceil(cont/n));
    cont=cont+1;
end
