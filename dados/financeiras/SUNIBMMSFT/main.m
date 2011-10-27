clear all; close all;

load SUNcloseDiasSemMod.txt;
load IBMcloseDiasSemMod.txt;
load MSFTcloseDiasSemMod.txt;
serie(1,:)=(SUNcloseDiasSemMod);
serie(2,:)=(IBMcloseDiasSemMod);
serie(3,:)=(MSFTcloseDiasSemMod);
serie=serie(:,1287:end);

conj_trval=252;
serie_trval=serie(:,1:conj_trval);
serie_teste=serie(:,conj_trval+1:end);


%outliers%%%%%%%%%%%%%%%%%%%%%%%%
s=load('sunibmmsft_estimada.txt');
x=load('sunibmmsft.txt');

%Falsos alarmes detectados por SCICA
p1=[189];
p2=[83 105 217 221];
p3=[105];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);

serie_teste=x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%outliers%%%%%%%%%%%%%%%%%%%%%%%%
s=load('sunibmmsft_estimada.txt');
x=load('sunibmmsft.txt');

%Falsos alarmes detectados por MCICA
p1=[189];
p2=[29 83 189 221];
p3=[105 189];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);

serie_teste=x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%outliers%%%%%%%%%%%%%%%%%%%%%%%%
s=load('sunibmmsft_estimada.txt');
x=load('sunibmmsft.txt');
%Falsos alarmes detectados SEM ICA
p1=[189];
p2=[29 49 83 221];
p3=[105 189];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);

serie_teste=x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%