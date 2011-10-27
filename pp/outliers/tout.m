function [out,mout]=tout(x,win,alpha)
%
%	[out,mout]=tout(x,win,alpha)
%
%  finds outliers in x by using local estimates of sigma and a t test
%
%	x = input data vector assumed normal but with outliers
%  win = length of half window 
%  alpha = Pr(false declaration) 
%
%  out = logical (0,1) vector of same size as x; outliers marked by 1, all else 0
%  mout = mean of x in the two half windows

nx=length(x);
out=logical(zeros(size(x)));
mout=zeros(size(x));
thresh=tinv(1-alpha/2,2*win-1); % put alpha/2 in each tail, df is 2*win-1

% at index k a mu and sigma are estimated based on the preceding and succeding win values  
% then a t test is performed at k to see if the observed value is consistent with
% the local estimates

if 2*win+1 > nx
   error('not enough data in vector x');
end
nk=nx-2*win; % nk=1 if nx=2*win+1;
for k=1:nk
   k1=k+win; 
   start1=k1-win;stop1=start1+win-1;	% 
   start2=k1+1;stop2=start2+win-1;
   indexes=[[start1:stop1],[start2:stop2]]; % indexes centered at k1 for the two windows
   m=mean(x(indexes));
   mout(k1)=m;
   sig=std(x(indexes));
   tval=(x(k1)-m)/(sig*sqrt((2*win+1)/(2*win)));	% based on pooled estimator of sigma
   if abs(tval) > thresh
      out(k1)=1;
   end
end

