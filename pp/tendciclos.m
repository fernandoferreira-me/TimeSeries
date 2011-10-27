function [residuo,retirada]=tendciclos(sinal,grau,nc)

% Esta fç retira a tendencia de ordem n e depois retira os ciclos senoidais

% clear all;
close all;
 
base=(1:length(sinal))';

Ns=length(sinal);
%Ns=1024;

NC=floor(Ns/2);

coefs=polyfit(base,sinal,grau);

sd = sinal;
for k=1:grau+1,
    sd=sd-coefs(k)*base.^(grau-k+1);
end

fsd=fft(sd,Ns);
maxi=max(abs(fsd));

ccos=flipud(real([fsd; fsd(1)])/(floor(Ns/2)));
csen=flipud(imag([fsd; fsd(1)])/(floor(Ns/2)));

w=(0:Ns-1)*2*pi/Ns;

% Retirando as componentes

subplot(2,1,1);
%figure;
plot(sinal);
hold on;
sdsc=sd;
fsdsc=fft(sdsc,Ns);
plot(sd,'k');
%grau
%size(sinal)
%size(sd)
plot(sinal-sd,'r');
%title(['Sinal original e Sinal sem tendência de grau ',num2str(grau)]);
%figure;
subplot(2,1,2);
stem((0:Ns-1)/Ns,abs(fsd));
maxi1=max(abs(fsd));
axis([0 0.5 0 1.2*maxi1]);
%title('Espectro do sinal sem tendencia');


num_comp=0;
comps=[];

% nc=input('Entre com o numero de componentes a ser retiradas: ');

%pause;

%figure;
for k=1:nc,
    % resp=input('Tirar a componente de maior energia? (Sim=1/Nao=0)');
    resp=1; 
    if resp==0
       break
    end    
    ind=find(abs(fsdsc)==max(abs(fsdsc)));
    comps(k)=ind(1);
    %sdsc=sdsc-(ccos(ind(1))*cos(w(ind(1))*base)+csen(ind(1))*sin(w(ind(1))*base)); 
    %fsdsc=fft(sdsc,Ns);
    fsdsc(ind)=0;%energia_residual;fsdsc(Ns+2-ind(1))=energia_residual;
    sdsc=real(ifft(fsdsc));
    stem(abs(fsdsc));
    %close all;
    subplot(2,1,1)
    plot(sinal);
    hold on;
    plot(sd,'k');
    plot(sdsc,'r');
    title(['Sinal original, Sinal sem tendência de grau ',num2str(grau),' e Sinal sem Ciclos']);
    subplot(2,1,2);
    stem(abs(fsdsc));
    maxi=max(abs(fsdsc));
    axis([0 Ns/2 0 maxi1]);
    title('Espectro do sinal sem tendencia, com a retirada dos ciclos');

    %stem(abs(fsdsc));
    %hold on;
    %axis([0 250 0 maxi]);
    fprintf(1,'Retirada a componente %d.\n',ind(1)); 
    num_comp=num_comp+1;	
    %pause;
end

% Plotando espectro antes e espectro depois

figure;
%subplot(2,1,1);
stem(0:length(fsdsc)-1,abs(fsd));
title('Espectro de Fourier');% Antes de remover os componentes de frequência');
xlabel('frequência');ylabel('Energia');
axis([0 Ns/10 0 maxi1+1]);
%subplot(2,1,2);
figure;
stem(0:length(fsdsc)-1,abs(fsdsc));
title('Espectro de Fourier');% Após remover os componentes de frequência');
xlabel('frequência');ylabel('Energia');
axis([0 Ns/10 0 maxi1+1]);


% normalizando 
norma=2*max(sdsc);
sdsc=sdsc/norma;

retirada.comps=comps;
retirada.ccos=ccos;
retirada.csen=csen;
retirada.w=w;
retirada.norma=norma;
retirada.coefs=coefs;

residuo=sdsc;