function  train( Model )
%TRAIN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
import NYCTaxi.XGBoost

switch Model.Type
    case 'XGBoost'
        Model.model=XGBoost(Model.trainingset.Predictors,Model.trainingset.Response,...
            Model.options.NumIter,Model.options.opts) ;
end
end

