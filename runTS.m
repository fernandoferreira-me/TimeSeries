% Author: Fernando Ferreira
% email: fferreira@lps.ufrj.br
% Oct 2011
clear, clc

% Load data
%serie = load('./flour-price.dat')';
%serie_trval = serie(:, 1:length(serie)-30);
%serie_test  = serie(:, length(serie)-30+1:end);

%addpath('dados/sinteticos');
[serie_trval, serie_test] = sinteticas(0);

% Load Object
TS = TimeSeries(serie_trval);
% Apply ICA (FastICA - SOBIRO)

%%%
%Preprocessing
%%%
TS.preprocess()

%%%
% Estimator
%%%

TS.createEstimatorModel()