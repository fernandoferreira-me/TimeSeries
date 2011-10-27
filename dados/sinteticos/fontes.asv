function [fontes_sinteticas] = fontes(amostras)
%Sintetiza as fontes independentes

rand('state',0);
randn('state',0);%zera o gerador de numero aleatorios;
%tendencia linear%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ruido=0.1;
f=50;
[s1 xs1]=seno(f,amostras,ruido);
ruido=0.1;
[xtb]=tendencia_linear(1,70,amostras,ruido);
xtbn=normalizacao(xtb,3);
xtbn=xtbn+0.1*xs1;
%figure;plot(xtbn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tendencia estocastica%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ruido=0.1;
f=30;
[s2 xs2]=seno(f,amostras,ruido);
ruidote=0.5;
xinicial=0.3;
xest = tendencia_estocastica(xinicial, ruidote,amostras);
xestn=normalizacao(xest,3)+0.02*xs2;
figure;plot(xestn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sazonalidade%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ruido=0.1;
f=10;
ps=5;%período da sazonalidade
[s xs]=seno(f,amostras,ruido);
sazonalidade=intsaz(xs(ps+1:amostras),ps,xs(1:ps));
[sn]=normalizacao(sazonalidade,1);
sn=0.4*sn;
%figure;plot(sn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ciclos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ruido=0.1;
f4=2;
[s4 xs4]=seno(f4,amostras,ruido);
f5=2.2;
[s5 xs5]=seno(f5,amostras,ruido);
f6=2.4;
[s6 xs6]=seno(f6,amostras,ruido);
ciclos=xs4+xs5+xs6;
[cn]=normalizacao(ciclos,1);
%figure;plot(cn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Heterocedasticidade%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ruido=0.1;
f=25;
[s7 xs7]=seno(f,amostras,ruido);
t=(1:amostras)./amostras;
residuo=exp(t).*xs7;
[hn]=normalizacao(residuo,1);
hn=0.2*hn;
%figure;plot(hn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Ruido%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0.1*randn(1,amostras);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SNR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[snr_xtbn] = sinal_ruido(xtbn,r)
[snr_xestn] = sinal_ruido(xestn,r)
[snr_sn] = sinal_ruido(sn,r)
[snr_cn] = sinal_ruido(cn,r)
[snr_hn] = sinal_ruido(hn,r)
[snr_r] = sinal_ruido(r,r)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fontes_sinteticas=[xtbn; xestn; sn; cn; hn; r];

%Plot
[n1, n2]=size(fontes_sinteticas);
figure;
for i=1:n1
subplot(3,2,i);plot(fontes_sinteticas(i,:));
end

end

