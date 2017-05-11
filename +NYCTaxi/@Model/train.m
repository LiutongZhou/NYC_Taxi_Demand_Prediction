function  train( Model )
%TRAIN 此处显示有关此函数的摘要
%   此处显示详细说明
import NYCTaxi.XGBoost

switch Model.Type
    case 'XGBoost'
        Model.model=XGBoost(Model.trainingset.Predictors,Model.trainingset.Response,...
            Model.options.NumIter,Model.options.opts) ;
end
end

