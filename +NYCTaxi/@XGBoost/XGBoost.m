classdef XGBoost
    %XGBOOST 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        model
    end
    
    methods
        %% Constructor 
        function obj=XGBoost(training_X,training_Y,maxIters,opts) 
            obj.model=SQBMatrixTrain( training_X, training_Y, maxIters, opts );
        end
        %% Methods
        function response=predict(obj,predictors)
            response=SQBMatrixPredict(obj.model,predictors);
        end        
    end
    %% Static Methods
    methods(Static,Hidden)
        error=loss(x,md)
    end
end

