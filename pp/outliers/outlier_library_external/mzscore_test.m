function [] = mzscore_test()
%
% ZSCORE uses the Modified Z-sccore method to label outliers assuming the
% data are normally distributed. This method replaces the average by the
% median and the standard deviation by the median of absolute deviations
% (MAD). These estimators are more robust to outliers.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% The variable 'thresh' is the maximum threshold and its default value
% is 3.5.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
%
% [] = mzscore_test() returns a message in the Command Window saying if the
% tests passed or there was some problem during execution.
%
% Created by Francisco Augusto Alcaraz Garcia
%            alcaraz_garcia@yahoo.com
%
% References:
%
% 1) B. Iglewicz; D.C. Hoaglin (1993). How to Detect and Handle Outliers.
% ASQC Basic References in Quality Control, vol. 16, Wisconsin, US.


% Test sample from Ref. 1).
% INPUTS:
x = [2.1 2.6 2.4 2.5 2.3 2.1 2.3 2.6 8.2 8.3]';
x_date = cellstr(['03/01/2005'; '04/01/2005';
    '05/01/2005'; '06/01/2005'; '07/01/2005';
    '10/01/2005'; '11/01/2005'; '12/01/2005';
    '13/01/2005'; '14/01/2005']);
thresh = 3.5;
dist = 0;

% OUTPUTS:
mzscore_test = [-1.57383333333333;0.674499999999998;-0.224833333333334;
    0.224833333333332;-0.674500000000000;-1.57383333333333;
    -0.674500000000000;0.674499999999998;25.8558333333333;26.3054999999999;];
maxmz_test = 2.84604989415154;
outlier_test = {'13/01/2005','Series1';'14/01/2005','Series1';};
outlier_num_test = [9,1;10,1;];


% Normal transformation
if dist == 1,
    x = log(x);
end

% Check for validity of inputs
if ~isnumeric(x) || ~isreal(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array, x must be positive for log-normality, and x_date must be a string table.')
end

[n, c] = size(x);
mad = median(abs((x-repmat(median(x),n,1))));
mzscore = 0.6745*(x-repmat(median(x),n,1))./repmat(mad,n,1);
[i,j] = find(abs(mzscore) > thresh);
maxmz = (n-1)/sqrt(n);

if ~isempty(i),
    outlier = [x_date(i) cellstr(strcat('Series', num2str(j)))];
    outlier_num = [i j];
else
    outlier = ('No outliers have been identified!');
    outlier_num = ('No outliers have been identified!');
end

if isequal(round(mzscore_test.*10^5)./10^5, round(mzscore.*10^5)./10^5) && ...
        isequal(round(maxmz_test.*10^5)./10^5, round(maxmz.*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

