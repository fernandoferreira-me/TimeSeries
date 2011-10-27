function [x_sm err_norm outlier outlier_num] = expsm(x, x_date, k, alpha, stdexpsm, alpha_std)
%
% The function 'expsm' generates exponential smoothing series from the
% original data according to the smmoothing parameter 'alpha'. Data points
% will be classified as outliers when the moving absolute normalized error
% is greater than 'k' standard deviations.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% 'x_date' is a column vector (cell array) containing the dates of the
% corresponding data in 'x'.
%
% 'k' indicates the number of standard deviations on the forecast error.
%
% 'alpha' is the smmoothing factor for the original series. Values close
% to 1 give greater weight to recent changes in the data.
%
% 'stdexpsm' indicates if the moving standard deviation of the errors is
% calculated via exponential smoothing (stdexpsm = 1) or not. This is more
% appropriate when data series are non-stationary and we want to give
% more/less weight to errors closer to the present. Default value is 1.
%
% 'alpha_std' is the smoothing factor for the exponential smoothing
% estimation of the moving standard deviation of errors. The default value
% is 0.2.
%
% [x_sm err_norm outlier outlier_num] = expsm(...) returns the following:
% x_sm          - Smooth series
% err_norm      - Normalized deviation, i.e., (x_{t}-x_sm_{t})/std_{t}
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
% 1) Z.W. Kundzewicz; J. Ihringer; E.J. Plate; J.G. Strele (1989). Outliers
% in Groundwater Quality Time Series. Groundwater Management: Quantity
% and Quality (Proceedings of the Benidorm Symposium, October), IAHS
% Publication n. 188.


% Check number of input arguements
if (nargin < 4) || (nargin > 6),
    error('Requires four to six input arguments.')
end

% Define default values
if nargin == 4,
    stdexpsm = 1;
    alpha_std = 0.2;
elseif nargin == 5
    alpha_std = 0.2;
end

% Check for validity of inputs
if ~isnumeric(x) || ~iscellstr(x_date),
    error('Input x must be a numeric array and x_date must be a string table.')
elseif alpha <= 0 || alpha >= 1,
    error('The smoothing factor must be between zero and one.')
end

[n, c] = size(x);

x_sm = x;
err = zeros(n,c);
err_std = zeros(n,c);
    for i = 2:n
        x_sm(i,:) = alpha.*x(i-1,:) + (1-alpha).*x_sm(i-1,:);
        err(i,:) = x(i,:) - x_sm(i,:);
        err_std(i,:) = std(err(2:i,:));
    end
err_std(2,:) = NaN;

if stdexpsm == 1,
    var_sm = zeros(n,c);
    for i = 3:n
        var_sm(i,:) = alpha_std .* (err(i-1,:) - mean(err(2:i,:))).^2 + (1-alpha_std).*var_sm(i-1,:);
    end
    std_sm = sqrt(var_sm);
    std_sm(2,:) = NaN;
    err_norm = err./std_sm;
else
    err_norm = err./err_std;
end

[i1,j1] = find(abs(err_norm) > k);

if ~isempty(i1),
    outlier = [x_date(i1) cellstr(strcat('Series', num2str(j1)))];
    outlier_num = [i1 j1];
else
    outlier = ('No outliers have been identified!');
    outlier_num = ('No outliers have been identified!');
end

