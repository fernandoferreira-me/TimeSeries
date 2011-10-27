function [Rmax lambda r_out outlier outlier_num] = gesd(x, x_date, r, sided, alpha, dist)
%
% The Generalized ESD procedure ('gesd'), tests for up to a prespecified
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
% 'alpha' specifies the significant level. By default 'alpha' = 0.05.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
%
% [Rmax lambda r_out outlier outlier_num] = gesd(...) returns the following:
% Rmax          - indicates the maximum absolute z-score for iteration r_{i}.
%                 Iterations {1, ..., r} correspond to the rows.
% lambda        - critical values for each iteration {1, ..., r} (rows).
% r_out         - highest number of the iteration {1, ..., r} where Rmax >
%                 lambda, indicating the values to be considered outliers
% outlier       - cell array specifying the date and the series number (column
%                 number in 'x') where the potential outliers are situated.
% outlier_num   - matrix providing row and column numbers of the values in
%                 'x' considered as potential outliers.
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


% Check number of input arguements
if (nargin < 3) || (nargin > 6)
    error('Requires three to six input arguments.')
end

% Define default values
if nargin == 3,
    sided = 1;
    alpha = 0.05;
    dist = 0;
elseif nargin == 4,
    alpha = 0.05;
    dist = 0;
elseif nargin == 5,
    dist = 0;
end

% Normal transformation
if dist == 1,
    x = log(x);
end

if sided == 1,
   alpha = alpha/2;
end

% Check for validity of inputs
if ~isnumeric(x) || ~isreal(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
elseif alpha <= 0 || alpha >= 1,
    error('The confidence level must be between zero and one.')
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

