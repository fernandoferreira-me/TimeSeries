function [x] = financeiras_online(ticker_fileName,firstDay,lastDay,Freq,benchTicker,Criteria)
%Faz download das series on-line

acoes=importdata(ticker_fileName);
n_stocks=size(acoes,1);

[x]=GetTickersData(firstDay, ...
                        lastDay , ...
                        n_stocks, ... 
                        ticker_fileName, ... 
                        Freq, ... 
                        Criteria, ...
                        benchTicker);

conj_trval=247;
serie_trval=[x.Open(1:conj_trval,:) x.High(1:conj_trval,:) x.Low(1:conj_trval,:) x.Close(1:conj_trval,:)];
serie_teste=[x.Open(conj_trval+1:end,:) x.High(conj_trval+1:end,:) x.Low(conj_trval+1:end,:) x.Close(conj_trval+1:end,:)];

serie_trval=serie_trval';
serie_teste=serie_teste';


end

