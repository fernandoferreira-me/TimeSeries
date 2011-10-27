function [serie_teste] = serie_corrigida(tipo)
%Carrega a série corrigida
switch tipo
    case 'simuladas'
        serie_teste=load('serie_teste_corrigida.txt');
    case 'amd2000'
        serie_teste=load('amdyahoo2000_corrigida.txt');
        serie_teste=serie_teste(:,1:162);        
    case 'sunibmmsft'
end
end

