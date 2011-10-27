function [] = testboxplot_test()
%
% The 'testboxplot' identifies outliers that lie 'k' times over the
% interquantile rante (Q3-Q1). A boxplot using the standard Matlab function
% 'boxplot' is also provided by default.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% The variable 'k' is a multiplier of the interquantile range (Q3-Q1). The
% default value is 2.
%
% The function also provides an option ('tukey') to use the quantile
% computation suggested by Tukey. It can take the default value 0 (not
% applied) or 1 (apply Tukey approach).
%
% The variable 'bplot' indicates if a boxplot is provided (=1, default) or
% omitted (=0).
%
% [] = testboxplot_test() returns a message in the Command Window saying if the
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
% 2) J.W. Tukey (1977). Exploratory Data Analysis. Addison Wesley.


% Test sample from Ref. 1).
% INPUTS:
x = [2.1 2.6 2.4 2.5 2.3 2.1 2.3 2.6 8.2 8.3]';
x_date = cellstr(['03/01/2005'; '04/01/2005';
    '05/01/2005'; '06/01/2005'; '07/01/2005';
    '10/01/2005'; '11/01/2005'; '12/01/2005';
    '13/01/2005'; '14/01/2005']);
k = 2;
tukey = 0;
bplot = 0;

% OUTPUTS:
Q1_test = 2.3;
Q3_test = 2.6;
outlier_test = {'13/01/2005','Series1';'14/01/2005','Series1';};
outlier_num_test = [9,1;10,1;];


[n, c] = size(x);

if tukey == 0,
    Q1 = quantile(x, 0.25);
    Q3 = quantile(x, 0.75);
else
    [xsort, ix] = sort(x);
    f = ((n+1)/2+1)/2;
    if isinteger(f),
        Q1 = xsort(f,:);
        Q3 = xsort(end+1-f,:);
    else
        Q1 = (xsort(fix(f),:) + xsort(fix(f)+1,:))/2;
        Q3 = (xsort(end+1-fix(f),:) + xsort(end+1-fix(f)+1,:))/2;
    end
end

[i1,j1] = find(x < repmat(Q1-k*(Q3-Q1),n,1));
[i2,j2] = find(x > repmat(Q3+k*(Q3-Q1),n,1));

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

if bplot == 1,
    boxplot(x, 'notch', 'on', 'whisker', k, 'symbol', 'r.')
end

if isequal(round(Q1_test.*10^5)./10^5, round(Q1.*10^5)./10^5) && ...
        isequal(round(Q3_test.*10^5)./10^5, round(Q3.*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

