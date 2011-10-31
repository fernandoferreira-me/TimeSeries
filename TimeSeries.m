% Author: Fernando Ferreira
% email: fferreira@lps.ufrj.br
% Oct 2011

classdef TimeSeries < hgsetget
	properties
		ts_original                   % Original set of series to analyze
		ts                            % Timeseries
		model = cell({})              % cell containing features from the series
		nnParams = cell({})             % Parameters for NN
	end
	methods
		function obj = TimeSeries(serie)
			obj.ts_original = serie;
			obj.ts = serie;
			nSeries =  size(serie,1);
			obj.model.has_heteroscedastic = false(1,nSeries);
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

		function removeHeteroscedastic(obj)
			[fs, n] = obj.removeNaN(obj.ts);
			[nSeries,nEvents] =size(fs);
			for i = 1:nSeries
				serie = fs(i,:);
				obj.plotSerie(serie);
				fprintf('\nRemove heteroscedastic using logarithmic function?');
				if yesno
					obj.model.has_heteroscedastic(i) = true;
					serie = serie ./exp((1:nEvents)/nEvents);
				end
				fs(i,:) = serie;
			end
			fprintf('\n');
			fs = obj.addNaN(fs, n);
			obj.ts = fs;
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

		function removeStochasticTrend(obj)
			[fs, n] = obj.removeNaN(obj.ts);
			ndiff = obj.ordint(fs);
			fprintf('\n Suggested number of root unit: ');
			disp(ndiff);
			for i=1:length(ndiff)
				serie = fs(i,:);
				ndiff(i) = input('Number of unitary root should be used? ');
				fs_diff = diff(serie, ndiff(i));
				nan_array = NaN(1, ndiff(i));
				fs_diff = [nan_array fs_diff];
				fs(i,:) = fs_diff;
			end
			fs = obj.addNaN(fs, n);
			obj.ts = fs;
			obj.model.n_unit_root = ndiff;
		end

		function removeSeasonality(obj)
			[fs, n] = obj.removeNaN(obj.ts);
			%Using functions written by Faier
			%TODO : re-coding
			addpath('pp/')
			addpath('auxiliar/')
			[serie, modelsazon] = ppsazon(fs);
			fs = obj.addNaN(serie, n);
			obj.ts = fs;
			obj.model.seasonality = modelsazon;
		end

		function removeCycles(obj)
			[fs, n] = obj.removeNaN(obj.ts);
			%Using functions written by Faier
			%TODO : re-coding
			addpath('pp/')
			addpath('auxiliar/')
			[serie, modelciclos] = ppciclos(fs);
			fs = obj.addNaN(serie, n);
			obj.ts = fs;
			obj.model.cycles = modelciclos;
		end

		function preprocess(obj)
			%  Heteroscedastic
			obj.removeHeteroscedastic()
			% Remove Trends
			obj.removeStochasticTrend()
			% Remove Seasons
			obj.removeSeasonality()
			% Remove cycles
			obj.removeCycles()
		end

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
				logical(idivide(int32(sum(no_corr,2)),int32(nSerie)))';
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
							input(cumindex+1:cumindex+n, event+1-events_to_ignore) = ...
								fs(k, event - used_lags{k});
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

		function createEstimator(obj, nnobj)
			obj.model.estimator.net = cell(size(obj.ts,1),1)
			for index=1:size(obj.ts,1)
				if ~obj.model.estimator.use_random_walk
					input  = obj.model.estimator.input{index};
					target = obj.model.estimator.target{index};
					nnobj.train(input, target);
					obj.model.estimator.net{index} = nnobj.best_net;
				end
			end
		end%createEstimator
	end%methods
end
