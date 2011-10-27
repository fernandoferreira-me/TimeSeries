function [ serie_sem_NaN, nans ] = removeNaN(serie)
%REMOVENAN remove os NaN's do vetor
serie_sem_NaN = serie(~isnan(serie));
nans=sum(isnan(serie));
end

