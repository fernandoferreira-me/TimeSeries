function [xn,rm,rd]=normalizacao(x,tipo);
%Jose Marcio Faier - jmfaier@gmail.com
%x: series de entrada [dimensoes(quantidade de series) x amostras(dias, anos etc)]
%tipo: 1-media zero e desvio 1   2-media zero e maximo (-1 e 1) 3- maximo (0 e 1)
%xn: series normalizadas 
%rm=media
%rd=desvio

switch tipo
    case 1
        m=mean(x');
        rm=repmat(m',1,size(x,2));
        d=std(x');
        rd=repmat(d',1,size(x,2));
        xn=(x-rm);
        xn=xn./rd;
        
    case 2
        m=mean(x');
        rm=repmat(m',1,size(x,2));
        xn=(x-rm);
        d=max(abs(xn'));
        rd=repmat(d',1,size(x,2));
        xn=xn./rd;
        
    case 3
        d=max(x');
        rd=repmat(d',1,size(x,2));
        rm=mean(x'); %so para validar a saida
        xn=x./rd;
   
end
        