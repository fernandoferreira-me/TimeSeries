function [Q1 Q3 MC outlier outlier_num] = adjboxplot(x, x_date, k)
%
% The 'adjboxplot' improves the outlier labeling capabilities of the
% boxplot approach in the presence of skewed data. A robust measure of
% skewness, the medcouple ('MC'), is introduced in the test.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% The parameters calibrated in the references for k=1.5 are used in this
% test. However, it is possible to define the value of k in the formula,
% though the results would not be optimal. Default value for k = 1.5. 
% 
% The 'adjboxplot' is equivalent to the 'testboxplot' for the same value of
% 'k' when MC=0, i.e., the data are symmetric.
%
% [Q1 Q3 MC outlier outlier_num] = adjboxplot(...) returns the following information:
% Q1            - 25% quantile
% Q3            - 75% quantile
% MC            - Medcouple measure of skewness. MC>0 indicates right skew and
%                 MC<0 left skew.
% outlier       - cell array specifying the date and the series number (column
%                 number in 'x') where the potential outliers are situated.
% outlier_num   - matrix providing row and column numbers of the values in
%                 'x' considered as potential outliers.
%
% The 'adjboxplot' function requires the 'medcouple' function to be
% available in the working directory.
%
% Created by Francisco Augusto Alcaraz Garcia
%            alcaraz_garcia@yahoo.com
%
% References:
%
% 1) E. Vanderviere; M. Huber (2004). An Adjusted Boxplot for Skewed
% Distributions. COMPSTAT'2004 Symposium, Physica-Verlag/Springer.
%
% 2) G. Brys; M. Hubert; P.J. Rousseeuw (2005). A Robustification of
% Independent Component Analysis. Journal of Chemometrics 19(5-7),
% pp. 364-375.
%
% 3) J.W. Tukey (1977). Exploratory Data Analysis. Addison Wesley.


% Check number of input arguements
if nargin < 2 || nargin > 3,
    error('Requires two to three input arguments.')
end

% Define default values
if nargin == 2,
    k = 1.5;
end

% Check for validity of inputs
if ~isnumeric(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
end

[n, c] = size(x);

Q1 = quantile(x, 0.25);
Q3 = quantile(x, 0.75);

MC = medcouple(x);
k1 = -3.5*(MC>=0);
k1 = k1 - 4*(MC<0);
k3 = 4*(MC>=0);
k3 = k3 + 3.5*(MC<0);

[i1,j1] = find(x < repmat(Q1 - k*exp(k1.*MC).*(Q3-Q1),n,1));
[i2,j2] = find(x > repmat(Q3 + k*exp(k3.*MC).*(Q3-Q1),n,1));

if (isempty(i1)+isempty(i2)) == 0,
    outlier = [x_date(i1) cellstr(strcat('Series', num2str(j1)));
    x_date(i2) cellstr(strcat('Series', num2str(j2)))];
    outlier_num = [i1 j1; i2 j2];
elseif isempty(i1),
    outlier = [x_date(i2) cellstr(strcat('Series', num2str(j2)))];
    outlier_num = [i2 j2];
elseif isempty(i2),
    outlier = [x_date(i1) cellstr(strcat('Series', num2str(j1)))];
    outlier_num = [i1 j1];
else
    outlier = ('No outliers have been identified!');
    outlier_num = ('No outliers have been identified!');
end

