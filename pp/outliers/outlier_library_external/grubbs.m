function [Gmax_loop Gmin_loop G2_loop lambda1_loop lambda2_loop outlier outlier_num] = grubbs(x, x_date, sided, alpha, dist, nmin)
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
% 'alpha' specifies the significant level. By default 'alpha' = 0.05.
%
% The variable 'dist' indicates if the series are assumed to be normal
% (default) or log-normally distributed. It can take the values 0 (normal)
% or 1 (log-normal).
%
% 'nmin' specifies the minimum number of observations, either in the
% original series or after removing outliers, before the algorithm stops.
% The default value is 6.
%
% [Gmax_loop Gmin_loop G2_loop lambda1_loop lambda2_loop outlier outlier_num outlier] =
% = gesd(...) returns the following:
% Gmax_loop          - indicates the statistic for the max observation as
%                      outlier in each loop (rows).
% Gmin_loop          - indicates the statistic for the min observation as
%                      outlier in each loop (rows).
% G2_loop            - indicates the statistic for the max and min
%                      observations as outliers in each loop (rows).
% lambda1_loop       - critical values for the max or mmin observation as
%                      outlier in each loop (rows).
% lambda2_loop       - critical values for both the max and mmin
%                      observation as outliers in each loop (rows).
% outlier            - cell array specifying the date and the series number (column
%                      number in 'x') where the potential outliers are situated.
% outlier_num        - matrix providing row and column numbers of the values in
%                      'x' considered as potential outliers.
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


% Check number of input arguements
if (nargin < 2) || (nargin > 6)
    error('Requires two to six input arguments.')
end

% Define default values
if nargin == 2,
    sided = 1;
    alpha = 0.05;
    dist = 0;
    nmin = 6;
elseif nargin == 3,
    alpha = 0.05;
    dist = 0;
    nmin = 6;
elseif nargin == 4,
    dist = 0;
    nmin = 6;
elseif nargin == 5,
    nmin = 6;
end

% Normal transformation
if dist == 1,
    x = log(x);
end

if sided == 1,
   alpha1 = alpha/2;
end

% Check for validity of inputs
if ~isnumeric(x) || ~isreal(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
elseif alpha <= 0 || alpha >= 1,
    error('The confidence level must be between zero and one.')
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

