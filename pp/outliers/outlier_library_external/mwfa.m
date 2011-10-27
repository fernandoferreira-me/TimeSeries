function [xr score mov_mean mov_std Dstat outlier outlier_num] = mwfa(x, x_date, cal, k, alpha, gamma)
%
% The Moving Window Filtering Algorithm, 'mwfa', is an outlier detection
% method in which a neighborhood of observations, called a filtering
% window, is used to assess the validity of a new observation on the basis
% of its relative distance from the closest neighborhood. Its
% implementation is similar to the Z-score but with moving mean and standard
% deviations. Also, it is possible to calibrate three parameters ('k','alpha',
% 'gamma') to the data set.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% 'cal' indicates if the function should perform a pre-defined grid
% optimization to find out optimal values of the triplet ('k','alpha',
% 'gamma'). The default value is 0. The best combination would be the one
% minimizing the 'D' statistic in 'Dstat'. The number of outliers 'noutl'
% identified in the series is also provided in 'Dstat'.
%
% 'k' is the window for the moving average and moving standard deviation.
% It is a numerical value indicating the number of lags.
%
% 'alpha' indicates the number of standard deviations that an observation
% should be higher/lower than the moving average to be considered as
% outlier.
%
% 'alpha' specifies the significant level. By default 'alpha' = 0.05.
%
% 'gamma' is a parameter to avoid zero variances produced by sequences of
% 'k' equal values.
%
% [xr score mov_mean mov_std Dstat outlier outlier_num] = mwfa(...) returns
% the following:
% xr            - Data series where the outliers have been substituted by the
%                 previous observation. A different approach can be easily
%                 implemented by modifying the code.
% mov_mean      - Series of moving average for the filtering window 'k'.
% mov_std       - Series of moving standard deviation for the filtering window 'k'.
% Dstat         - Table generated when 'cal~=0' where the different
%                 combinations of {'k','alpha','gamma','D', 'noutl'} in this
%                 order (column vectors) are provided for all combinations of 
%                 'k'=5:60, 'alpha'=1:0.1:4, and 'gamma'=0.01:0.01:1.
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
% 1) J.M.Puigvert Gutierrez; J.F. Gregori (2008). Clustering Techniques
% Applied to Outlier Detection of Financial Market Series Using a Moving
% Window Filtering Algorithm. ECB Working Paper Series, n. 948, October.
% 
% 2) C.T. Brownlees; G.M. Gallo (2006). Financial Econometric Analysis at
% Ultra-High Frequency: Data Handling Concerns. Computational Statistics
% & Data Analysis 51, pp. 2232-2245.


% Check number of input arguements
if (nargin < 2) || (nargin > 6),
    error('Requires two to six input arguments.')
end

% Define default values
if nargin == 2,
    cal = 0;
    k = 5;
    alpha = 3;
    gamma = 0.02;
elseif nargin == 3,
    k = 5;
    alpha = 3;
    gamma = 0.02;
elseif nargin == 4,
    alpha = 3;
    gamma = 0.02;
elseif nargin == 5
    gamma = 0.02;
end

% Check for validity of inputs
if ~isnumeric(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
end

[n, c] = size(x);
xr = x;

if cal==0,
    score = nan(n,c);
    mov_mean = nan(n,c);
    mov_std = nan(n,c);
    outlier_mat = zeros(n,c);
    d = zeros(n,c);

    for i = k+1:n
        mov_mean(i,:) = mean(xr(i-k:i-1,:));
        score(i,:) = xr(i,:) - mov_mean(i,:);
        mov_std(i,:) = std(xr(i-k:i-1,:));
        temp = abs(score(i,:)) > (alpha .* mov_std(i,:) + gamma);
        xr(i,temp) = x(i-1,temp);
        outlier_mat(i,:) = temp*1;
        temp1 = xr(i,:) >= (x(i,:) + mov_std(i,:));
        temp2 = xr(i,:) < (x(i,:) - mov_std(i,:));
        d(i,temp1)= xr(i,temp1)-(x(i,temp1)+mov_std(i,temp1));
        d(i,temp2)= (x(i,temp2)-mov_std(i,temp2))-xr(i,temp2);
    end
    Dstat = mean(d.^2);

    [i1,j1] = find(outlier_mat);
    if ~isempty(i1),
        outlier = [x_date(i1) cellstr(strcat('Series', num2str(j1)))];
        outlier_num = [i1 j1];
    else
        outlier = ('No outliers have been identified!');
        outlier_num = ('No outliers have been identified!');
    end

else
    Dstat = [];
    steps = 56*31*100;
    step = 0;
    h = waitbar(0,'Please wait...');
    for k = 5:60
        for alpha = 1:0.1:4
            for gamma = 0.01:0.01:1
                score = nan(n,c);
                mov_mean = nan(n,c);
                mov_std = nan(n,c);
                outlier_mat = zeros(n,c);
                d = zeros(n,c);

                for i = k+1:n
                    mov_mean(i,:) = mean(xr(i-k:i-1,:));
                    score(i,:) = xr(i,:) - mov_mean(i,:);
                    mov_std(i,:) = std(xr(i-k:i-1,:));
                    temp = abs(score(i,:)) > (alpha .* mov_std(i,:) + gamma);
                    xr(i,temp) = x(i-1,temp);
                    outlier_mat(i,:) = temp*1;
                    temp1 = xr(i,:) >= (x(i,:) + mov_std(i,:));
                    temp2 = xr(i,:) < (x(i,:) - mov_std(i,:));
                    d(i,temp1)= xr(i,temp1)-(x(i,temp1)+mov_std(i,temp1));
                    d(i,temp2)= (x(i,temp2)-mov_std(i,temp2))-xr(i,temp2);
                end
                [i1,j1] = find(outlier_mat);
                Dstat = [Dstat; k alpha gamma mean(d.^2) size(i1,1)];
                step = step + 1;
                waitbar(step / steps);
            end
        end
    end
    close(h) 
    xr = [];
    score = [];
    mov_mean = [];
    mov_std = [];
    outlier = [];
    outlier_num = [];
end

