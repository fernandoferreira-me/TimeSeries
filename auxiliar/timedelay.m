function [serie_deslocada] = timedelay(serie,td)
%Aplica um atraso na série

serie_deslocada=[serie(:,td+1:end); serie(:,1:end-td)];

end

