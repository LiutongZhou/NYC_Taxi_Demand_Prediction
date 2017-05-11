classdef Model< handle
    %MODEL 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        Type char
        trainingset struct=struct('Predictors',[],'Response',[]);
        testset struct=struct('Predictors',[],'Response',[]);
        model
        options struct
        validation
    end
    
    methods
        %% constructor
        function obj=Model(type)
            if nargin>0
                obj.Type=type;
            end
        end
        %% Ordinary Methods
        % set method for property: Type
        function set.Type(obj,str)
            ValidStrings={'Random Forest','XGBoost','LSBoost','ANN','Regression Tree'};
            obj.Type=validatestring(str,ValidStrings);
            initialize_opts(obj);
        end
        % method 0
        train( obj )
        %method 1
        response = predict( obj,predictors )
        % method 2
        validation_results= Validate (obj)
    end
end
function initialize_opts(obj)
switch obj.Type % set property:options
    case 'XGBoost'
        obj.options=struct;
        obj.options.opts.loss='squaredloss';
        obj.options.opts.shrinkageFactor=0.1;
        obj.options.opts.subsamplingFactor=0.5;
        obj.options.opts.maxTreeDepth = uint32(10);
        obj.options.NumIter=uint32(600);
        if ~isempty(obj.trainingset)
        obj.options.opts.mtry=uint32(ceil(sqrt(size(obj.trainingset.Predictors,2))));
        obj.trainingset.Predictors=single(obj.trainingset.Predictors);
        end
        if ~isempty(obj.testset)
        obj.testset.Predictors=single(obj.testset.Predictors);
        end
end
end

