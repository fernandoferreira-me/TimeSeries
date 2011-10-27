function [] = adjboxplot_test()
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
% [] = adjboxplot_test() returns a message in the Command Window saying if the
% tests passed or there was some problem during execution.
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


% Test sample.
% INPUTS:
x = [2431 2250 2311 2210 2329 2263 2353 2251 2275 2185 1958]';
x_date = cellstr(['03/01/2005'; '04/01/2005';
    '05/01/2005'; '06/01/2005'; '07/01/2005';
    '10/01/2005'; '11/01/2005'; '12/01/2005';
    '13/01/2005'; '14/01/2005'; '17/01/2005']);
k = 1.5;

% OUTPUTS:
Q1_test = 2220;
Q3_test = 2324.5;
MC_test = 0.0357142857142857;
outlier_test = {'17/01/2005','Series1';};
outlier_num_test = [11,1;];


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

if isequal(round(Q1_test.*10^5)./10^5, round(Q1.*10^5)./10^5) && ...
        isequal(round(Q3_test.*10^5)./10^5, round(Q3.*10^5)./10^5) && ...
        isequal(round(MC_test.*10^5)./10^5, round(MC.*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

