function [seno,seno_ruido]=seno(f,amostras,snr);
%frequencia da senoide
%numero de amostras
%nivel de ruido na senoide

for i=1:amostras
    seno(i)=sin(2*pi*i*(f/amostras));
    seno_ruido(i)=seno(i)+(randn(1)*snr);
end

%figure;plot(seno_ruido);hold on;plot(seno,'r');