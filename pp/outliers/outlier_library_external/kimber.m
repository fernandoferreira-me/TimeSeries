function [ss s outlier outlier_num] = kimber(x, x_date, r, alpha)
%
% The 'kimber' test adapts the Generalized ESD procedure to check for up to
% 'r' upper outliers from an exponential distribution. An approximation to
% the critical values is used instead of the published tables, which can
% reduce accuracy.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% 'r'  is the predefined number of outliers to check.
%
% 'alpha' specifies the significant level. By default 'alpha' = 0.05.
%
% [ss s outlier outlier_num] = gesd(...) returns the following:
% ss            - matrix containing the values of the statistic
% s             - approximation to the critical values depending on the
%                 values of 'n' and 'r'.
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
% 1) A.C. Kimber (1982). Tests for Many Outliers in an Exponential Sample.
% Journal of the Royal Statistical Society, Series C (Applied Statistics),
% 31(3), pp. 263-271.
%
% 2) B. Iglewicz; D.C. Hoaglin (1993). How to Detect and Handle Outliers.
% ASQC Basic References in Quality Control, vol. 16, Wisconsin, US.


% Check number of input arguements
if (nargin < 3) || (nargin > 4),
    error('Requires three to four input arguments.')
end

% Define default values
if nargin == 3,
    alpha = 0.05;
end

% Check for validity of inputs
if ~isnumeric(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
elseif alpha <= 0 || alpha >= 1,
    error('The confidence level must be between zero and one.')
end

[n, c] = size(x);
[xr, ix] = sort(x);
s = zeros(r,1);
ss = zeros(r,c);
outlier = [];
outlier_num = [];

for j = 1:r,
    u = ((alpha/r) / nchoosek(n,j))^(1/(n-j));
    s(j,1) = (1-u)/(1+(j-1)*u);
    
    ss(j,:) = xr(n+1-j,:)./sum(xr(1:n+1-j,:));
end

for i = 1:c,
    [i1,j1] = find(ss(:,i) > s);
    if ~isempty(i1),
        outlier = [outlier; x_date(ix(end-max(i1)+1:end)) repmat(cellstr(strcat('Series', num2str(i))),max(i1),1)];
        outlier_num = [outlier_num; ix(end-max(i1)+1:end,i) repmat(i,max(i1),1)];
    end
end

