function response = predict( Model,predictors )
%PREDICT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

response = Model.model.predict(predictors);
end

