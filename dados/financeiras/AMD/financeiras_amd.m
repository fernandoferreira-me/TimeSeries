function [serie_trval, serie_teste] = financeiras_amd(bl)
%Retorna as series trval e teste para AMD
%bl: bloco da série
%tdica_lag: atraso utilizado nas séries
%todas_tdica: (1) para aplicar tdica em todas e (0) para aplica

%xyahoo=load('amdyahoo.txt');2004 e 2006
%xstock=load('amdstock.txt');2004 e 2006

xyahoo=load('amdyahoo19962006.txt');xyahoo=xyahoo(1:4,:);%19/01/1996 a 01/09/2006
xstock=load('amdstock19962006.txt');xstock=xstock(1:4,:);%19/01/1996 a 01/09/2006

tdica_lag=0;%atraso aplicado nas séries
serie_tdica=1;%Série alvo
todas_tdica=2;%(1)todas series e todas series tdica, (2) todas series e a serie alvo tdica, (3) serie alvo e serie alvo tdica

if tdica_lag>0    
   switch todas_tdica
        case 1%todas series e todas series tdica
        xyahoo=[xyahoo(:,tdica_lag+1:end);xyahoo(:,1:end-tdica_lag)];
        xstock=[xstock(:,tdica_lag+1:end);xstock(:,1:end-tdica_lag)];
        case 2%todas series e a serie alvo tdica
        xyahoo=[xyahoo(:,tdica_lag+1:end);xyahoo(serie_tdica,1:end-tdica_lag)];
        xstock=[xstock(:,tdica_lag+1:end);xstock(serie_tdica,1:end-tdica_lag)];
        case 3%serie alvo e serie alvo tdica
        xyahoo=[xyahoo(serie_tdica,tdica_lag+1:end);xyahoo(serie_tdica,1:end-tdica_lag)];
        xstock=[xstock(serie_tdica,tdica_lag+1:end);xstock(serie_tdica,1:end-tdica_lag)];
    end
end

switch bl
    case 1
%Bloco 01
%serie_trval=xstock(:,1:241);%Serie trval de 19/Jan/1996 a 31/Dez/1996
%serie_teste=xstock(:,242:494);%Serie_teste certificada de 02/Jan/1997 a 31/Dez/1997
serie_trval=xyahoo(:,1:241);
serie_teste=xyahoo(:,242:494);
    case 2
%Bloco 02
%serie_trval=xstock(:,242:494);%Serie trval de 02/Jan/1997 a 31/Dez/1997
%serie_teste=xstock(:,495:746);%Serie_teste certificada de 02/Jan/1998 a 31/Dez/1998
serie_trval=xyahoo(:,242:494);
serie_teste=xyahoo(:,495:746);
    case 3
%Bloco 03
serie_trval=xstock(:,495:746);%Serie trval de 02/Jan/1998 a 31/Dez/1998
serie_teste=xstock(:,747:998);%Serie_teste certificada de 04/Jan/1999 a 31/Dez/1999
%serie_trval=xyahoo(:,495:746);
%serie_teste=xyahoo(:,747:998);
    case 4
%Bloco 04
%serie_trval=xstock(:,747:998);%Serie trval de 04/Jan/1999 a 31/Dez/1999
%serie_teste=xstock(:,999:1250);%Serie trval de 03/Jan/2000 a 29/Dez/2000
serie_trval=xyahoo(:,747:998);
serie_teste=xyahoo(:,999:1250);
%xxx=load('serie_amd2000_out.txt');% 252+ [19 28 94 122 155] [20 27 93 125 153] [18 26 92 124 154][21 26 95 123 156];
%serie_trval=xxx(:,1:252);
%serie_teste=xxx(:,253:end);
    case 5
%Bloco 05
%serie_trval=xstock(:,999:1250);%Serie trval de 03/Jan/2000 a 29/Dez/2000
%serie_teste=xstock(:,1251:1498);%Serie trval de 02/Jan/2001 a 31/Dez/2001
serie_trval=xyahoo(:,999:1250);
serie_teste=xyahoo(:,1251:1498);
    case 6
%Bloco 06
%serie_trval=xstock(:,1251:1498);%Serie trval de 02/Jan/2001 a 31/Dez/2001
%serie_teste=xstock(:,1499:1750);%Serie trval de 02/Jan/2002 a 31/Dez/2002
serie_trval=xyahoo(:,1251:1498);
serie_teste=xyahoo(:,1499:1750);
    case 7
%Bloco 07
%serie_trval=xstock(:,1499:1750);%Serie trval de 02/Jan/2002 a 31/Dez/2002
%serie_teste=xstock(:,1751:2002);%Serie trval de 02/Jan/2003 a 31/Dez/2003
serie_trval=xyahoo(:,1499:1750);
serie_teste=xyahoo(:,1751:2002);
    case 8
%Bloco 08
%serie_trval=xstock(:,1751:2002);%Serie trval de 02/Jan/2003 a 31/Dez/2003
%serie_teste=xstock(:,2003:2254);%Serie trval de 02/Jan/2004 a 31/Dez/2004
serie_trval=xyahoo(:,1751:2002);
serie_teste=xyahoo(:,2003:2254);
    case 9
%Bloco 09
%serie_trval=xstock(:,2003:2254);%Serie trval de 02/Jan/2004 a 31/Dez/2004
%serie_teste=xstock(:,2255:2506);%Serie trval de 03/Jan/2005 a 30/Dez/2005
serie_trval=xyahoo(:,2003:2254);
serie_teste=xyahoo(:,2255:2506);
    case 10
%Bloco 10
%serie_trval=xstock(:,2255:2506);%Serie trval de 03/Jan/2005 a 30/Dez/2005
%serie_teste=xstock(:,2507:2675);%Serie trval de 03/Jan/2006 a 01/Set/2006
serie_trval=xyahoo(:,2255:2506);
serie_teste=xyahoo(:,2507:2675);
end

end

