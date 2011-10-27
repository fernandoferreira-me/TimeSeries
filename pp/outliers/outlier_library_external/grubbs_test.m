function [] = grubbs_test()
%
% The 'grubbs' function performs an iterative test to check for the max,
% min or both observations as outliers. The test checks first for the max
% or min data point to be outlier and if any of the two observations is
% labeled as outlier then removes it from the sample and checks for the
% next max or min. If both of the test for max or min are not passed, then
% it checks if both max and min data points can be labeled as outliers. The
% test stops when no outliers are identified or the data sample is less
% than 'nmin'. The first part of the algorithm is also called the 'Modified
% Thompson Tau' procedure.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% 'sided' indicates if the critical values are from a two-sided
% distribution (default) or one-sided ('sided' = 0).
%
% 'alpha' specifies the significan level. By default 'alpha' = 0.05.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
%
% 'nmin' specifies the minimum number of observations, either in the
% original series or after removing outliers, before the algorithm stops.
% The default value is 6.
%
% [] = grubbs_test() returns a message in the Command Window saying if the
% tests passed or there was some problem during execution.
%
% Created by Francisco Augusto Alcaraz Garcia
%            alcaraz_garcia@yahoo.com
%
% References:
%
% 1) H.A David; H.O. Hartley; E.S. Pearson (1954). The Distribution of
% the Ratio, in a Single Normal Sample, of Range to Standard Deviation.
% Biometrika 41(3), pp. 482-493.
%
% 2) F.E. Grubbs (1969). Procedures for Detecting Outlying Observations
% in Samples. Technometrics 11(1), pp. 1-21.
%
% 3) NIST/SEMATECH e-Handbook of Statistical Methods (2010),
% http://www.itl.nist.gov/div898/handbook/.
%
% 4) S.L.R. Ellison; V.J. Barwick; T.J.D. Farrant (2009). Practical
% Statistics for the Analytical Scientist. A Bench Guide. RSC Publishing,
% 2nd ed., Cambridge.


% Test sample from Ref. 2).
% INPUTS:
x = [-1.40 -0.44 -0.30 -0.24 -0.22 -0.13 -0.05 0.06 0.10 0.18 0.20 0.39 ...
    0.48 0.63 1.01]';
x_date = cellstr(['03/01/2005'; '04/01/2005';
    '05/01/2005'; '06/01/2005'; '07/01/2005';
    '10/01/2005'; '11/01/2005'; '12/01/2005';
    '13/01/2005'; '14/01/2005'; '17/01/2005';
    '18/01/2005'; '19/01/2005'; '20/01/2005';
    '21/01/2005']);
sided = 1;
alpha = 0.05;
dist = 0;
nmin = 6;

% OUTPUTS:
Gmax_loop_test = [1.80052692176423;2.21864454189618;];
Gmin_loop_test = [2.57373707163476;1.39310238677202;];
G2_loop_test = [4.37426399339899;3.61174692866819;];
lambda1_loop_test = [2.54830777174334;2.50732085257884;];
lambda2_loop_test = [4.17298177185772;4.09671538097411;];
outlier_test = {'03/01/2005','Series1';};
outlier_num_test = [1,1;];


% Normal transformation
if dist == 1,
    x = log(x);
end

if sided == 1,
   alpha1 = alpha/2;
end

% Check for validity of inputs
if ~isnumeric(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
end

[n, c] = size(x);
xr = x;
j4 = 1;
j7 = 1;
j9 = 1;
outlier = [];
outlier_num = [];
Gmax_loop = [];
Gmin_loop = [];
G2_loop = [];
lambda1_loop = [];
lambda2_loop = [];

if n <= nmin,
    error('Time series should contain more than %d data points.', nmin);
else
    while (sum(j4) + sum(j7) + sum(j9))~= 0,
        nr = n - sum(isnan(xr));
        [i1,j1] = find(nr > nmin);
        if isempty(j1),
            disp(['Time series after removal of outliers contain less than ', num2str(nmin), ' data points.']);
            break
        end
        p1 = 1 - alpha1./nr;
        lambda1 = tinv(p1,nr-2).*(nr-1)./sqrt((nr-2+tinv(p1,nr-2).^2).*nr);
        
        Gmax = (nanmax(xr) - nanmean(xr))./nanstd(xr);
        [i2,j2] = find(xr == repmat(nanmax(xr),n,1)); % location of max
        [i3,j3] = find(Gmax > lambda1);
        j4 = ismember(j1,j3)';
        
        Gmin = (nanmean(xr) - nanmin(xr))./nanstd(xr);
        [i5,j5] = find(xr == repmat(nanmin(xr),n,1)); % location of min
        [i6,j6] = find(Gmin > lambda1);
        j7 = ismember(j1,j6)';
       
        p2 = 1 - alpha./(nr.*(nr - 1));
        lambda2 = sqrt((2.*(nr-1).*tinv(p2,nr-2).^2)./(n-2+tinv(p2,n-2).^2));
        G2 = (nanmax(xr) - nanmin(xr))./nanstd(xr);
        
        if sum(j4)~=0,
            xr(i2(j4),j2(j4)) = NaN;
            outlier = [outlier; x_date(i2(j4)) cellstr(strcat('Series', num2str(j2(j4))))];
            outlier_num = [outlier_num; i2(j4) j2(j4)];
        end
        
        if sum(j7)~=0,
            xr(i5(j7),j5(j7)) = NaN;
            outlier = [outlier; x_date(i5(j7)) cellstr(strcat('Series', num2str(j5(j7))))];
            outlier_num = [outlier_num; i5(j7) j5(j7)];
        end
        
        if sum(j4)==0 && sum(j7)==0,
            [i8,j8] = find(G2 > lambda2);
            j9 = ismember(j1,j8)';
            if sum(j9)~=0,
                xr(i2(j9),j2(j9)) = NaN;
                xr(i5(j9),j5(j9)) = NaN;
                outlier = [outlier; x_date(i2(j9)) cellstr(strcat('Series', num2str(j2(j9)))); ...
                    x_date(i5(j9)) cellstr(strcat('Series', num2str(j5(j9))))];
                outlier_num = [outlier_num; i2(j9) j2(j9); i5(j9) j5(j9)];
            end
            j9 = 0;
        end
        Gmax_loop = [Gmax_loop; Gmax];
        Gmin_loop = [Gmin_loop; Gmin];
        G2_loop = [G2_loop; G2];
        lambda1_loop = [lambda1_loop; lambda1];
        lambda2_loop = [lambda2_loop; lambda2];
    end
end

if isequal(round(Gmax_loop_test*10^5)./10^5, round(Gmax_loop*10^5)./10^5) && ...
        isequal(round(Gmin_loop_test*10^5)./10^5, round(Gmin_loop*10^5)./10^5) && ...
        isequal(round(G2_loop_test*10^5)./10^5, round(G2_loop*10^5)./10^5) && ...
        isequal(round(lambda1_loop_test*10^5)./10^5, round(lambda1_loop*10^5)./10^5) && ...
        isequal(round(lambda2_loop_test*10^5)./10^5, round(lambda2_loop*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

