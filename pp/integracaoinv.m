function [serie_rec ] = integracaoinv(residuo,x0)
%Recompõe a série diferenciada (integrada) de ordem 1
%y: resíduo da série diferenciada
%x0:amostra inicial
serie_rec=[x0 cumsum(residuo)+x0];


