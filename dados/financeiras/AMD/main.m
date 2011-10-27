%xyahoo=load('amdyahoo.txt');2004 a 2006
%xstock=load('amdstock.txt');2004 a 2006

xyahoo=load('amdyahoo19962006.txt');%19/01/1996 a 01/09/2006
xstock=load('amdstock19962006.txt');%19/01/1996 a 01/09/2006
load('datas19962006.mat');%19/01/1996 a 01/09/2006


e=xyahoo-xstock;%diferença entre as séries
figure;plot(e(1,1:2506));hold on;plot(e(2,1:2506),'r');hold on;plot(e(3,1:2506),'g');hold on;plot(e(4,1:2506),'m');

hold on;
lx=[241 241];ly=[-10 10];plot(lx,ly,'-.k');%1996
hold on;
lx=[494 494];ly=[-10 10];plot(lx,ly,'-.k');%1997
hold on;
lx=[746 746];ly=[-10 10];plot(lx,ly,'-.k');%1998
hold on;
lx=[998 998];ly=[-10 10];plot(lx,ly,'-.k');%1999
hold on;
lx=[1250 1250];ly=[-10 10];plot(lx,ly,'-.k');%2000
hold on;
lx=[1498 1498];ly=[-10 10];plot(lx,ly,'-.k');%2001
hold on;
lx=[1750 1750];ly=[-10 10];plot(lx,ly,'-.k');%2002
hold on;
lx=[2002 2002];ly=[-10 10];plot(lx,ly,'-.k');%2003
hold on;
lx=[2254 2254];ly=[-10 10];plot(lx,ly,'-.k');%2004
hold on;
lx=[2506 2506];ly=[-10 10];plot(lx,ly,'-.k');%2002
%Centro dos blocos: 120(1996),367(1997),620(1998),872(1999),1124(2000),1374(2001),1624(2002),1876(2003),2128(2004),2380(2005) 
axis([0 2506 -10 13])

%Plot a evoluçao da QD
qdstock=[0.9221 0.9940 0.9860 0.9070 1.0 1.0 0.9930 0.9750 0.9890];
qdyahoo=[0.9163 0.9919 0.9746 0.9070 0.9990 0.9990 0.9970 0.9750 0.9890];
figure;plot(qdstock,'.-');hold on;plot(qdyahoo,'.-r');
axis([0 9 0.90 1.01])
grid;
%Plot a evolução do modelo
qmstock=[0.8181 0.8186 0.8075 0.8038 0.7931 0.7927 0.7979 0.8324 0.8216];
qmyahoo=[0.8195 0.8194 0.7894 0.8181 0.7318 0.7694 0.8145 0.8323 0.8216];
figure;plot(qmstock,'.-');hold on;plot(qmyahoo,'.-r');


%Plot
figure;
for i=1:size(e,1)    
subplot(size(e,1)/2,2,i);
plot(e(i,:));
end

%serie_trval=xstock(:,1:252);%Serie trval 2004
%serie_teste=xyahoo(:,253:504);%Serie teste 2005
serie_trval=xstock(:,1:504);%Serie trval 2004 e 2005
serie_teste=xyahoo(:,505:end);%Serie trval 2004 e 2005


%AMD2000 com outliers
xxx=load('serie_amd2000_out.txt');% 252+ [19 28 94 122 155] [20 27 93 125 153] [18 26 92 124 154][21 26 95 123 156];
serie_trval=xxx(:,1:252);
serie_teste=xxx(:,253:end);

out_scica_abe=[13    14    19    28    44    46    49    63    67    69    70    72    73    75    76    90    92    94   100   103   104   106   118   122   131   149   150   155   160   162];
out_scica_max=[14    20    27    44    45    48    67    70    71    73    79    90    91    93   100   103   107   117   125   128   153  162];
out_scica_min=[4     6    18    19    26    44    57    63    65    66    68    70    71    72    73    75    79    83    89    92    98   100   103   118   124   131   148   160   162];
out_scica_fech=[15    16    17    21    26    44    45    47    48    62    66    70    71    72    73    74    75    79    80    89    91    99   103   117   123   127   128   156   162];

y=load('amdyahoo2000_estimada.txt');
ajuste=[NaN NaN;NaN NaN;NaN NaN;NaN NaN;];
yy=[ajuste y];

serie_teste(1,[out_scica_abe])=yy(1,[out_scica_abe]);
serie_teste(2,[out_scica_max])=yy(2,[out_scica_max]);
serie_teste(3,[out_scica_min])=yy(3,[out_scica_min]);
serie_teste(4,[out_scica_fech])=yy(4,[out_scica_fech]);

save amdyahoo2000_corrigida.txt serie_teste -ascii
