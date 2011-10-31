classdef swirlTraining
	properties
		params;
		G ;
		tp;
		ants_movements;
		best_net;
		HFC;
	end
	methods
		function obj =  swirlTraining()
			addpath('swirl/')
			obj.params.max_neurons  = 10;
			obj.params.max_iter     = 100;
			obj.params.ants_factor  = 1;
			% Set parameters for the ants
			obj.params.antParams = [];
			%Set parameters nnet
			obj.params.netParams.trainClass = @gdNet;
			obj.params.netParams.number_of_nets = 20;
			obj.HFC = 1;
			obj.params.antParams.beta = 0.5;
			obj.params.antParams.alpha = 2.;
			obj.params.antParams.rho = .5;
            obj.params.factor_train= 0.7;
        end

		function train(obj, input, target)
			% normalize
				data = input;
				data = data - repmat(mean(data,2), 1, size(data, 2));
				data = data ./ repmat(std(data, 0, 2), 1, size(data,2));
				trainInd   =  1:2:length(data);
				valInd     =  2:2:length(data);
				obj.params.netParams.data       =  data;
				obj.params.netParams.target     =  target;
                indexes = randperm(length(data));
                num_train = round(length(indexes)*obj.params.factor_train);
				obj.params.netParams.trainInd  =  indexes(1:num_train);
				obj.params.netParams.valInd  =  indexes((num_train+1):end);
                addpath('swirl/')
				[obj.ants_movements, obj.tp, obj.tp_initial, obj.G] ...
                    = SWIRL(obj.HFC, obj.params);
		end

		function [best_net] = get.best_net(obj)
			[~, idx] = max(G);
			obj.best_net = obj.tp{idx}.nets{obj.bestIdx};
			best_net = obj.best_net;
		end
	end
end%classdef
