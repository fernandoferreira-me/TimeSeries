function [] = expsm_test()
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
% 'k' indicates the number of standard deviations on the forecast error
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
% [] = expsm_test() returns a message in the Command Window saying if the
% tests passed or there was some problem during execution.
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


% Test sample.
% INPUTS:
x = [9.206343;9.299992;9.277895;9.305795;
    9.275351;9.288729;9.287239;9.260973;
    9.303111;9.275674;9.272561;9.288454;
    9.255672;9.252141;9.297670;9.266534;
    9.256689;9.277542;9.248205;9.252107;
    9.276345;9.278694;9.267144;9.246132;
    9.238479;9.269058;9.248239;9.257439;
    9.268481;9.288454;9.258452;9.286130;
    9.251479;9.257405;9.268343;9.291302;
    9.219460;9.270386;9.218808;9.241185;
    9.269989;9.226585;9.258556;9.286184;
    9.320067;9.327973;9.262963;9.248181;
    9.238644;9.225073;];
x_date = {'03/01/2005';'04/01/2005';'05/01/2005';'06/01/2005';'07/01/2005';
    '10/01/2005';'11/01/2005';'12/01/2005';'13/01/2005';'14/01/2005';
    '17/01/2005';'18/01/2005';'19/01/2005';'20/01/2005';'21/01/2005';
    '24/01/2005';'25/01/2005';'26/01/2005';'27/01/2005';'28/01/2005';
    '31/01/2005';'01/02/2005';'02/02/2005';'03/02/2005';'04/02/2005';
    '07/02/2005';'08/02/2005';'09/02/2005';'10/02/2005';'11/02/2005';
    '14/02/2005';'15/02/2005';'16/02/2005';'17/02/2005';'18/02/2005';
    '21/02/2005';'22/02/2005';'23/02/2005';'24/02/2005';'25/02/2005';
    '28/02/2005';'01/03/2005';'02/03/2005';'03/03/2005';'04/03/2005';
    '07/03/2005';'08/03/2005';'09/03/2005';'10/03/2005';'11/03/2005';};
alpha = 0.7;
k = 3;
stdexpsm = 1;
alpha_std = 0.2;

% OUTPUTS:
x_sm_test = [9.20634300000000;9.20634300000000;9.27189730000000;9.27609569000000;
    9.29688520700000;9.28181126210000;9.28665367863000;9.28706340358900;
    9.26880012107670;9.29281773632301;9.28081712089690;9.27503783626907;
    9.28442915088072;9.26429914526422;9.25578844357927;9.28510553307378;
    9.27210545992213;9.26131393797664;9.27267358139299;9.25554557441790;
    9.25313857232537;9.26938307169761;9.27590072150928;9.26977101645278;
    9.25322370493583;9.24290241148075;9.26121132344423;9.25213069703327;
    9.25584650910998;9.26469065273300;9.28132499581990;9.26531389874597;
    9.27988516962379;9.26000085088714;9.25818375526614;9.26529522657984;
    9.28349996797395;9.23867199039219;9.26087179711766;9.23142713913530;
    9.23825764174059;9.26046959252218;9.23675037775665;9.25201431332700;
    9.27593309399810;9.30682682819943;9.32162914845983;9.28056284453795;
    9.25789555336139;9.24441946600842;];
err_norm_test = [NaN;NaN;0.306014055893081;1.23017399230971;-0.995640835428699;
    0.249309404816415;0.0230254474383053;-1.11600950057029;1.22677991886000;
    -0.635854662735471;-0.306226463914791;0.526549161795803;-1.25166780182780;
    -0.474665447905564;1.70071039349761;-0.683218641187384;-0.582119795469495;
    0.636902892913928;-1.04358886079627;-0.140796549792795;1.04860358158121;
    0.434086618468750;-0.453129149406691;-1.30925279398378;-0.742751036573805;
    1.34316080812905;-0.636685761868184;0.272051083333157;0.722659763538413;
    1.47226669028759;-1.32892559853992;1.07503705405349;-1.48115768605277;
    -0.118221045638586;0.513869839194783;1.44814854848541;-3.28403995148990;
    0.923523210766396;-1.24979019179169;0.272736922762410;0.985715808588106;
    -1.06244237794176;0.668209392452031;1.12171939246206;1.44457543911035;
    0.645149266192525;-1.92324987735061;-0.844588876869230;-0.514402062697800;
    -0.558427158409335;];
outlier_test = {'22/02/2005','Series1';};
outlier_num_test = [37,1;];


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

if isequal(round(x_sm_test*10^5)./10^5, round(x_sm*10^5)./10^5) && ...
        isequal(round(err_norm_test(3:end)*10^5)./10^5, round(err_norm(3:end)*10^5)./10^5) && ...
        isequal(outlier_test, outlier) && isequal(outlier_num_test, outlier_num),
    disp('All tests have passed.');
else
    disp('There is some error in the cash output. Please do not use the function.');
end

