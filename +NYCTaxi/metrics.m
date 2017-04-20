classdef metrics
    %METRICS 此处显示有关此类的摘要
    %   此处显示详细说明
    properties
     results table
    end
    properties(Constant)
        RMSE=@(y,yfit) norm(y-yfit)/sqrt(length(yfit));
        R_Squared=@ (y,yfit) 1-nansum((y-yfit).^2)/nansum((y-nanmean(y)).^2);
        MAPE=@(y,yfit) nanmean(abs(y-yfit)./(y+1));
        MAE=@(y,yfit) nanmean(abs(y-yfit));
    end
    
    methods
        function   obj=metrics(y,yfit)
            RMSE=obj.RMSE(y,yfit);
            R_Squared=obj.R_Squared(y,yfit);
            MAPE=obj.MAPE(y,yfit);
            MAE=obj.MAE(y,yfit);
            obj.results=table(RMSE,R_Squared,MAPE,MAE);
        end
    end
    
end

