function [] = testsaz(serie, numero_de_lags,nstd_correlacao )
%Plota a autocorrelacao da série para o teste da sazonalidade

serie_trval=serie';
for i=1:size(serie_trval,2)
    alv=i;
[acfi(:,i),lagsi(:,i),bounds(:,i)]=crosscorr(serie_trval(:,i),serie_trval(:,alv),numero_de_lags,nstd_correlacao); %CONFERIR
acf(:,i)=acfi(floor(size(acfi(:,i),1)/2)+1:end,i);
lags(:,i)=lagsi(floor(size(lagsi(:,i),1)/2)+1:end,i);
figure;stem((0:size(acf,1)-1),acf(:,i),'b.');hold on;plot([lags(1,i) lags(size(lags,1),i)+1],[bounds(1,i) bounds(1,i)],'k-');plot([lags(1,i) lags(size(lags,1),i)+1],[bounds(2,i) bounds(2,i)],'k-');
end


end

