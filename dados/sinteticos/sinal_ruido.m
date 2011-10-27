function [ SNR ] = sinal_ruido(sinal,ruido)
%Calcula a relação sinal-ruído
x=sinal;
RMS_sinal=sqrt((sum(x.*x))/size(x,2));
RMS_ruido=sqrt((sum(ruido.*ruido))/size(ruido,2));

%SNR - Relacao Sinal Ruido
SNR=10*log10(RMS_sinal/RMS_ruido);


end

