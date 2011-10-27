function [serie_trval, serie_teste] = financeiras_sunibmmsft()
%Retorna as series trval e teste para SUN, IBM e MSFT

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


end

