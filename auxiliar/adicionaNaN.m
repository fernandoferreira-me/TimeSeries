function [serie_com_nans] = adicionaNaN(serie,nans)
%Adiciona NaN
if nans~=0
NaNs=NaN(1,nans);%vetor de NaN para preecher a matris serie
serie_com_nans=[NaNs serie];
else
serie_com_nans=serie;
end
end

