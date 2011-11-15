function [saida_rec] = ppciclosinv(saida_estimada, modelo,sequenciatemporal)
%Inverte o preprocessamento readicioanando os ciclos
%saida_estimada: residuo estimado
%modelo: ciclos, e tend linear
%sequenciatemporal: amostra a partir da qual a séries começa. 

retirada=modelo{3};
for i=1:size(saida_estimada,1)
    for j=1:size(saida_estimada,2)
    %saida_rec(i,j)=reconstroi_tc(saida_estimada(i,j),retirada{i},j+sequenciatemporal);%OBS.:é preciso dizer o ponto de partida: sequenciatemporal
    saida_rec(i,j)=reconstroi_tc2(saida_estimada(i,j),retirada{i},j+sequenciatemporal);%reconstroi_tc2 deve ser utilizada como se for testar coma amostras inicial = 0
    end
end
end

