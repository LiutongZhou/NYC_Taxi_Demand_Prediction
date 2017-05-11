function Demand=add_holiday_mark(Demand)
%add_holiday_mark Demand.add_holiday_mark adds is_holiday column to Demand
%table
holiday_list=NYCTaxi.holidaygen(datestr(min(Demand.Demand.Properties.RowTimes)),...
                       datestr(max(Demand.Demand.Properties.RowTimes)));
holiday_list=holiday_list(:);                   
Demand.Demand.is_holiday= ismember(datestr(Demand.Demand.Properties.RowTimes,'yyyymmdd'),holiday_list);
end
