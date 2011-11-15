% Author: Fernando Ferreira
% email: fferreira@lps.ufrj.br
% Oct 2011
% Matlab 2011a required

classdef TimeSeries < hgsetget
	properties
		ts_original              % Original set of series to analyze
		ts                       % Timeseries
		model = cell({})         % cell containing features from the series
		nnParams = cell({})      % Parameters for NN
		test_serie
		test_serie_original
		input_test
		estimated_output
	end
	methods
		%% Set and get methods
		function obj = set.test_serie(obj, serie)
			obj.test_serie=serie;
			obj.test_serie_original= serie;
		end

		%% Core Methods
		function obj = TimeSeries(serie)
			obj.ts_original = serie;
			obj.ts = serie;
			nSeries =  size(serie,1);
			%% Temporary
			obj.nnParams.corr_lag  = 10;
			obj.nnParams.corr_nstd =  3; % 99%
		end

		function plotSerie(obj,serie)
			figure;
			hold on;
			plot(serie);
			grid on;
		end

		function fs = addNaN(obj,serie, n)
			if n ~= 0
				n_serie = size(serie,1);
				nan_matrix = NaN(n_serie, n);
				fs = [nan_matrix serie];
			else
				fs = serie;
			end
		end

		function [fs,n] = removeNaN(obj,serie)
			fs = serie;
			n = size(fs(:,isnan(fs(1,:))),2);
			fs(:,isnan(fs(1,:))) = [];
		end

		%% Pre-processing block
		function removeHeteroscedastic(obj,opt)
			if nargin == 1
				[fs, n] = obj.removeNaN(obj.ts);
				[nSeries,nEvents] =size(fs);
				obj.model.has_heteroscedastic = false(1,nSeries);
				for k= 1:nSeries
					serie = fs(k,:);
					obj.plotSerie(serie);
					fprintf('\nRemove heteroscedastic using logarithmic function?');
					if yesno
						obj.model.has_heteroscedastic(k) = true;
						serie = serie ./exp((1:nEvents)/nEvents);
					end
					fs(k,:) = serie;
				end
				fprintf('\n');
				fs = obj.addNaN(fs, n);
				obj.ts = fs;
			elseif nargin == 2
				if ~strcmpi(opt, 'test')
					err = MException('TimeSeries:removeHeteroscedastic', ...
					'Usage: removeHeteroscedastic() or removeHeteroscedastic(''test'')');
					throw(err);
				end
				if size(obj.test_serie,2) == 0
					err = MException('TimeSeries:removeHeteroscedastic', ...
					'No serie for testing. Use: TimeSerie::test_serie(serie) ');
					throw(err);
				end
				serie = obj.test_serie;
				if isfield(obj.model, 'has_heteroscedastic')
					[fs, n] = obj.removeNaN(serie);
					[nSeries,nEvents] =size(fs);
					if length(obj.model.has_heteroscedastic) ~= size(serie, 1)
						err = MException('TimeSeries:removeHeteroscedastic', ...
							'Model and given serie dimensions are not compatible.');
						throw(err);
					end
					H = repmat(...
						(obj.model.has_heteroscedastic)'...
						, 1, nEvents) ./ ...
						repmat(exp((1:nEvents)/nEvents), nSeries, 1);
					H(H==0)=1;
					fs = obj.addNaN(serie .* H, n);
					obj.test_serie = fs;
				else
					err = MException('TimeSeries:removeHeteroscedastic', ...
					'No model was created. You should probably run TimeSeries::preprocess().');
					throw(err);
				end
			end
			close all
		end

		function ndiff = ordint(obj, serie)
			nSerie = size(serie,1);
			ndiff = zeros(1, nSerie);
			for i=1:nSerie
				s = serie(1,:);
				has_root = true;
				DWbound = 5e-2;
				while has_root,
					[ADF, ~, ~, ~] = unitroot (s);
					if(ADF(3,4) <= 1e-1 && (abs(ADF(1,2)-2) < DWbound))
						has_root = false;
					elseif ADF(3,1) <= 0.1
						has_root = false;
					else
						ndiff(i) = ndiff(i) + 1;
						s = diff(s);
					end
				end
			end
		end


		function removeStochasticTrend(obj, opt)
			if nargin == 1
				[fs, n] = obj.removeNaN(obj.ts);
				ndiff = obj.ordint(fs);
				fprintf('\n Suggested number of root unit: ');
				disp(ndiff);
				for i=1:length(ndiff)
					ndiff(i) = input('Number of unitary root should be used? ');
				end
			elseif nargin == 2
				if ~strcmpi(opt, 'test')
					err = MException('TimeSeries:removeStochasticTrend', ...
					'Usage: removeStochasticTrend() or removeStochasticTrend(''test'')');
					throw(err);
				end
				if size(obj.test_serie,2) == 0
					err = MException('TimeSeries:removeStochasticTrend', ...
					'No serie for testing. Use: TimeSerie::test_serie(serie) ');
					throw(err);
				end
				if ~isfield(obj.model, 'n_unit_root')
					err = MException('TimeSeries:removeStochasticTrend', ...
					'No model was created. You should probably run TimeSeries::preprocess().');
					throw(err);
				end
				if length(obj.model.n_unit_root) ~= size(obj.test_serie, 1)
					err = MException('TimeSeries:removeStochasticTrend', ...
						'Model and given serie dimensions are not compatible.');
					throw(err);
				end
				[fs, n] = obj.removeNaN(obj.test_serie);
				ndiff = obj.model.n_unit_root;
			end
			obj.model.initial_condition= cell(length(ndiff));
			for k=1:length(ndiff)
				[fs_diff, X0] = diff2(fs(k,:), ndiff(k));
				nan_array = NaN(1, ndiff(k));
				fs(k,:) = [nan_array fs_diff];
				obj.model.initial_condition(k) = X0;
			end
			fs = obj.addNaN(fs, n);
			if nargin == 1
				obj.ts = fs;
				obj.model.n_unit_root = ndiff;
			elseif nargin == 2
				obj.test_serie = fs;
			end
		end

		function removeSeasonality(obj, opt)
			nSTD = 3;
			%Using functions written by Faier
			%TODO : re-coding
			%addpath('pp/')
			%addpath('auxiliar/')
			if nargin == 1
				[fs, n] = obj.removeNaN(obj.ts);
			%   Visual Test
				[nSeries, nEvents] = size(fs);
				residue = NaN(nSeries, nEvents);
				obj.model.seasonality = cell(nSeries,1);
				for k=1:nSeries
					[acf, ~, bounds] = crosscorr(fs(k,:), fs(k,:), nEvents-2, nSTD);
					acf = acf(floor(size(acf,1)/2)+2:end);
					p = figure(); hold on; grid on;
					stem(1:size(acf,1), acf, 'b.');
					plot([1 nEvents-2] , [bounds(1) bounds(1)], 'k-');
					plot([1 nEvents-2] , [bounds(2) bounds(2)], 'k-');
					title(sprintf('Visual test for serie %d', k));
					hold off;
					period = input(sprintf('Seasonality period for serie %d: ', k));
					close(p);
					y = zeros(nEvents-period,1);
					for index=1:(nEvents - period)
						y(index) = fs(index+period) - fs(index);
					end
					obj.model.seasonality{k}.period = period;
					obj.model.seasonality{k}.x0 = fs(1:period);
					residue(k,period+1:end) = y;
				end
				obj.ts = obj.addNaN(residue,n);
			elseif nargin == 2
				if ~strcmpi(opt, 'test')
					err = MException('TimeSeries:removeSeasonality', ...
					'Usage: removeSeasonality() or removeSeasonality(''test'')');
					throw(err);
				end
				if size(obj.test_serie,2) == 0
					err = MException('TimeSeries:removeSeasonality', ...
					'No serie for testing. Use: TimeSerie::test_serie(serie) ');
					throw(err);
				end
				if ~isfield(obj.model, 'seasonality')
					err = MException('TimeSeries:removeSeasonality', ...
					'No model was created. You should probably run TimeSeries::preprocess().');
					throw(err);
				end
				[fs, n] = obj.removeNaN(obj.test_serie);
				[nSeries, nEvents] = size(fs);
				residue = NaN(nSeries, nEvents);
				for k=1:nSeries
					period = obj.model.seasonality{k}.period;
					y = zeros(nEvents-period,1);
					for index=1:(nEvents - period)
						y(index) = fs(index+period) - fs(index);
					end
					residue(k,period+1:end) = y;
				end
				obj.test_serie = obj.addNaN(residue,n);
			end
		end

		function removeCycles(obj,opt)
			%Using functions written by Faier
			%TODO : re-coding
			addpath('pp/')
			addpath('auxiliar/')
			if nargin == 1
				[fs, n] = obj.removeNaN(obj.ts);
				[serie, modelciclos] = ppciclos(fs);
				fs = obj.addNaN(serie, n);
				obj.ts = fs;
				obj.model.cycles = modelciclos;
			elseif nargin == 2
				if ~strcmpi(opt, 'test')
					err = MException('TimeSeries:removeCycles', ...
					'Usage: removeCycles() or removeCycles(''test'')');
					throw(err);
				end
				if size(obj.test_serie,2) == 0
					err = MException('TimeSeries:removeCycles', ...
					'No serie for testing. Use: TimeSerie::test_serie(serie) ');
					throw(err);
				end
				if ~isfield(obj.model, 'cycles')
					err = MException('TimeSeries:removeCycles', ...
					'No model was created. You should probably run TimeSeries::preprocess().');
					throw(err);
				end
				[fs, n] = obj.removeNaN(obj.test_serie);
				[serie] = ppciclosop(fs, obj.model.cycles);
				fs = obj.addNaN(serie, n);
				obj.ts = fs;
			end
		end

		function preprocess(obj)
			%Gathers all functions concerned to preprocessing stage
			%  Heteroscedastic
			obj.removeHeteroscedastic()
			% Remove Trends
			obj.removeStochasticTrend()
			% Remove Seasons
			obj.removeSeasonality()
			% Remove cycles
			obj.removeCycles()
		end


		%% Pos-processing block
		function addCycles(obj)
		end

		function addSeasonality(obj)
			series = obj.output;
			[nSeries, nEvents] = size(series);
			for k=1:nSeries
				period = obj.model.seasonality{k}.period;

				% Ensure we have a whole number of periods in the current serie
				nPeriods = ceil(nEvents/period);
				x = [ series(k,:) NaN(1, nEvents - nPeriods*period) ];
				
				% Chop the serie into periods and add x0 to the beginning
				y = [ obj.model.seasonality{k}.x0; reshape(x, [period nPeriods])'];

				% Integrate on periods
				z = cumsum(y);

				% Get back to a single row
				fs = reshape(z', [1 nPeriod*period]);
				obj.output(k)= fs(1:nEvents);
			end
		end

		function addStochasticTrend(obj)
			series = obj.output;
			[nSeries, nEvents] = size(series);
			fs = zeros(nSeries, 1);
			for k=1:nSeries
				nRoot = obj.model.n_unit_root
				while nRoot ~= 0
					fs(k) = integrate(series(k), obj.model.initial_condition(k));
					nRoot = nRoot - 1;
				end
			end
			obj.output = fs;
		end

		function addHeteroscedastic(obj)
			series = obj.output;
			[nSeries, nEvents] = size(series);
			gaps = obj.output_gaps;
			H = zeros(nSeries, nEvents);
			for index=1:nSeries
				H(index) = obj.model.has_heteroscedastic(i) * exp(...
					(gaps(index):nEvents+gaps(index))...
						/(nEvents+gaps(index))...
				)
			end
			H(H==0)=1;
			fs = serie .* H;
			obj.output = fs;
		end

		%% Estimator block
		function assembleData(obj)
			close all;
			%% Study xcorrelations
			fs = obj.removeNaN(obj.ts);
			nSerie = size(fs,1);
			obj.model.estimator.used_lags = cell(nSerie);
			obj.model.estimator.input = cell(nSerie,1);
			obj.model.estimator.target = cell(nSerie,1);
			for index=1:nSerie % create one estimator for each serie
				for k=1:nSerie
					% Find correlation in the time window
					[xcf, ~, bounds] = crosscorr(fs(k,:)', fs(index,:)',...
						obj.nnParams.corr_lag, obj.nnParams.corr_nstd);
					xcf = xcf(floor(size(xcf,1)/2)+2:end);
					used_lags = find(abs(xcf) > bounds(1));
					obj.model.estimator.used_lags{index,k} = used_lags;
				end %end for k
			end %end for i
			no_corr = cellfun(@isempty, obj.model.estimator.used_lags);
			obj.model.estimator.use_random_walk = ...
				logical(sum(no_corr,2) == nSerie)';
			%% Assemble the estimator input and target dataset
			nNodes = sum(cellfun(@length, obj.model.estimator.used_lags),2);
			for index=1:nSerie
				if (~no_corr(index))
					cumindex = 0;
					nInputNodes = nNodes(index);
					used_lags = obj.model.estimator.used_lags(index, :);
					used_lags(cellfun(@isempty, used_lags))= {0};
					events_to_ignore  = 1 + max(cellfun(@(x) max(x),used_lags));
					input = zeros(nInputNodes, size(fs,2) - events_to_ignore);
					for k=1:nSerie
						n = length(used_lags{k});
						for event=events_to_ignore:size(fs,2)
							input(cumindex+1:cumindex+n, event+1-...
								events_to_ignore) = fs(k, event - used_lags{k});
						end
						cumindex = cumindex + n;
					end
				else
					input = fs(index, events_to_ignore-1 :end-1);
				end
				obj.model.estimator.input{index}  = input;
				obj.model.estimator.target{index} = fs(index, events_to_ignore:end);
			end
		end %assembleData

		function assembleDataForTest(obj)
			fs = obj.removeNaN(obj.test_serie);
			nSerie = size(fs,1);
			obj.input_test = cell(nSerie,1);
			nNodes = sum(cellfun(@length, obj.model.estimator.used_lags),2);
			for index = 1:nSerie
				if ~obj.model.estimator.use_random_walk
					cumindex = 0;
					nInputNodes = nNodes(index);
					used_lags = obj.model.estimator.used_lags(index, :);
					used_lags(cellfun(@isempty, used_lags))= {0};
					events_to_ignore  = 1 + max(cellfun(@(x) max(x),used_lags));
					input = zeros(nInputNodes, size(fs,2) - events_to_ignore);
					for k=1:nSerie
						n = length(used_lags{k});
						for event=events_to_ignore:size(fs,2)
							input(cumindex+1:cumindex+n, event+1-...
								events_to_ignore) = fs(k, event - used_lags{k});
						end
						cumindex = cumindex + n;
					end
				else
					input = fs(index, events_to_ignore-1 :end-1);
				end
				obj.input_test{index} = input;
			end
		end

		function createEstimator(obj, nnobj)
			obj.model.estimator.net = cell(size(obj.ts,1),1);
			for index=1:size(obj.ts,1)
				if ~obj.model.estimator.use_random_walk
					input  = obj.model.estimator.input{index};
					target = obj.model.estimator.target{index};
					nnobj.train(input, target);
					obj.model.estimator.net{index} = nnobj.best_net;
				end
			end
		end%createEstimator

		%% Applying model

		function applyModel(obj, test_serie)
			obj.test_serie = test_serie;
			% Preprocess test dataset
			obj.removeHeteroscedastic('test');
			obj.removeStochasticTrend('test');
			obj.removeSeasonality('test');
			obj.removeCycles('test');
			close all;
			% Format estimator input
			obj.assembleDataForTest();
			obj.estimated_output = cell(size(test_serie,1),1);
			for k=1:length(obj.model.estimator.use_random_walk)
				if obj.model.estimator.use_random_walk
					% The best estimator is the current event
					obj.estimated_output{k} = obj.input_test{k};
				else
					y = sim(obj.model.estimator.net{k}.net, obj.input_test{k});
					obj.estimated_output{k} = y;
				end
			end
			obj.estimator.output = obj.estimated_output;
			[obj.output, obj.output_gaps] = cropSeries(obj.estimated_output);
		end %applyModel
	end%methods
end

function [Y, X0] = diff2(X, n)
	X0 = zeros(n,1);
	Y = X;
	for k=1:n
		X0(k) = Y(1);
		Y=diff(Y,1);
	end
end

function [Y] = integrate(X, X0)
	Y = X;
	for k=length(X0):-1:1
		Y = [X0(k) cumsum(Y)+X0(k)]
	end
end

function [A, gaps] = cropSeries(series)
	nSeries = length(series);
	smaller_serie_length = min(cell2mat(cellfun(@x size(x,2), series)));
	A = cell2mat(cellfun(@x x(end-smaller_serie_length+1:end), series));
	gaps = cell2mat(cellfun(@(x) length(x)-smaller_serie_length+1, A, ...
		'UniformOutput', false));
end
