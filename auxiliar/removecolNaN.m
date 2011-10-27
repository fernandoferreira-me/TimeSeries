function [serie_sem_nan] = removecolNaN(serie)
%Remove as colunas iniciais da matriz, até a maior coluna com pelo menos 1 NaN
[i, j]=find(isnan(serie));
if ~isempty(j)
maxcol=max(j);
serie_sem_nan=serie(:,maxcol+1:end);
else
    serie_sem_nan=serie;
end
end

