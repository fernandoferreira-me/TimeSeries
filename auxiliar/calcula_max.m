function [m] = calcula_max(modelo)
%Calcula o tamanho da janela inicial para ajustar as séries

n=size(modelo{6}{1}{2},2);
for i=1:n
maior(i)=nanmax(nanmax(modelo{6}{i}{2}));
if sum(maior)==0%Se nenhum lag foi significativo, então utiliza-se a amostra anterior (ou a média das anteriores) para fazer a estimativa. Assim, deve-se acresentar maior deve ser igual a 1
    maior=1;
end
end
%ATENÇÃO: Gambiarra
gambiarra=0;%Atenção: esta gambiarra é para ser feita quando se inverte a ordem do pré-processamento ou há um erro na estimacao do valor maximo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
m=max([max(modelo{3})+ max(modelo{5})])+nanmax(maior)-gambiarra;%ajuste para equilibrar as amostras retiradas.

end

