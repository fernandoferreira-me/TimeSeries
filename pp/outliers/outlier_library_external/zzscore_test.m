function [] = zzscore_test()
%
% ZSCORE uses the Z-sccore method to label outliers assuming the data are
% normally distributed.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% The variable 'thresh' is the maximum threshold and its default value
% is 3.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
% 
% [] = zzscore_test() returns a message in the Command Window saying if the
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
thresh = 3;
dist = 0;

% OUTPUTS:
zzscore_test = [-0.578608330789699;-0.377702660376609;-0.458064928541846;
    -0.417883794459227;-0.498246062624464;-0.578608330789699;
    -0.498246062624464;-0.377702660376609;1.87244084825000;1.91262198233262;];
maxz_test = 2.84604989415154;
outlier_test = ['No outliers have been identified!';];
outlier_num_test = ['No outliers have been identified!';];


% Normal transformation
if dist == 1,
    x = log(x);
end

[n, c] = size(x);
zzscore = (x-repmat(mean(x),n,1))./repmat(std(x),n,1);
[i,j] = find(abs(zzscore) > thresh);
maxz = (n-1)/sqrt(n);

if ~isempty(i),
    outlier = [x_date(i) cellstr(strcat('Series', num2str(j)))];
    outlier_num = [i j];
else
    outlier = ('No outliers have been identified!');
    outlier_num = ('No outliers have been identified!');
end

if isequal(round(zzscore_test.*10^5)./10^5, round(zzscore.*10^5)./10^5) && ...
        isequal(round(maxz_test.*10^5)./10^5, round(maxz.*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

