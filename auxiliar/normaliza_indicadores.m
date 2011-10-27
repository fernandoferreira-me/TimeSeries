function [msen,nmse1n,nmse2n,rn,lag0n] = normaliza_indicadores(mse,nmse1,nmse2,r,lag0)
%Normaliza os indicadores do modelo
msen=1-(1./exp(1./(abs(mse))));
nmse1n=1-(1./exp(1./(abs(nmse1))));
nmse2n=1-(1./exp(1./(abs(nmse2))));
rn=1./exp(1./(abs(r)));
lag0n=abs(lag0);

end

