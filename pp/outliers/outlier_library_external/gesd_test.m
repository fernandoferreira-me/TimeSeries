function [] = gesd_test()
%
% The Generalized ESD procedure ('gesd') tests for up to a prespecified
% number 'r' of outliers and it is specially recommended when testing for
% outliers among data coming from a normal distribution.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% 'r' is the predefined number of outliers to check. It can be chosen
% somewhat higher than anticipated.
%
% 'sided' indicates if the critical values are from a two-sided
% distribution (default) or one-sided ('sided' = 1).
%
% 'alpha' specifies the significan level. By default 'alpha' = 0.05.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
%
% [] = gesd_test() returns a message in the Command Window saying if the
% tests passed or there was some problem during execution.
%
% Created by Francisco Augusto Alcaraz Garcia
%            alcaraz_garcia@yahoo.com
%
% References:
%
% 1) B. Iglewicz; D.C. Hoaglin (1993). How to Detect and Handle Outliers.
% ASQC Basic References in Quality Control, vol. 16, Wisconsin, US.
%
% 2) B. Rosner (1983). Percentage Points for a Generalized ESD Many-Outlier
% Procedure. Technometrics 25(2), pp. 165-172.


% Test sample from Ref. 1).
% INPUTS:
x = [2.1 2.6 2.4 2.5 2.3 2.1 2.3 2.6 8.2 8.3]';
x_date = cellstr(['03/01/2005'; '04/01/2005';
          '05/01/2005'; '06/01/2005';
          '07/01/2005'; '10/01/2005';
          '11/01/2005'; '12/01/2005';
          '13/01/2005'; '14/01/2005']);
r = 3;
sided = 1;
alpha = 0.05;
dist = 0;

% OUTPUTS:
Rmax_test = [1.91262198233262;2.65448049146915;1.31543953335730;];
lambda_test = [2.28995408447960;2.21500422332553;2.12664508719546;];
r_out_test = 2;
outlier_test = {'14/01/2005','Series1';'13/01/2005','Series1';};
outlier_num_test = [10,1;9,1;];

% Normal transformation
if dist == 1,
    x = log(x);
end

if sided == 1,
   alpha = alpha/2;
end

[n, c] = size(x);
xr = x;
Rmax = zeros(r,c);
lambda = zeros(r,c);
vname = strcat('r', strtrim(cellstr(num2str([1:r]'))));

for i = 1:r,
    nr = n - sum(isnan(xr));
    R.(char(vname(i))) = abs((xr - repmat(nanmean(xr),n,1))./repmat(nanstd(xr),n,1));
    Rmax(i,:) = nanmax(R.(char(vname(i))));
    [i1, j1] = find(R.(char(vname(i))) == repmat(Rmax(i,:),n,1));
    row.(char(vname(i))) = i1; % data structure
    col.(char(vname(i))) = j1; % data structure
    xr(i1,j1) = NaN;
    
    p = 1 - alpha./nr;
    lambda(i,:) = tinv(p,nr-2).*(nr-1)./sqrt((nr-2+tinv(p,nr-2).^2).*nr);
end

pos = Rmax > lambda;

r_out = zeros(1,c);
outlier = [];
outlier_num = [];
for i = 1:c,
    [i2, j2] = find(pos(:,i)==1);
    if ~isempty(max(i2)),
        r_out(1,i) = max(i2);
        for j=1:r_out(1,i),
            outlier = [outlier; x_date(row.(char(vname(j)))(col.(char(vname(j)))==i)) ...
                cellstr(strcat('Series', num2str(repmat(i,sum(col.(char(vname(j)))==i),1))))];
            outlier_num = [outlier_num; row.(char(vname(j)))(col.(char(vname(j)))==i) ...
                repmat(i,sum(col.(char(vname(j)))==i),1)];
        end
    end
end

if isequal(round(Rmax_test*10^5)./10^5, round(Rmax*10^5)./10^5) && ...
        isequal(round(lambda_test*10^5)./10^5, round(lambda*10^5)./10^5) && ...
        isequal(r_out_test, r_out) && isequal(outlier_test, outlier) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end
    
