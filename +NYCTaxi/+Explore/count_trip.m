function count_trip(pickuplat,pikcuplon,dropofflat,dropofflon,passenger)

from_JFK=isinJFK(pickuplat,pikcuplon);
to_JFK=isinJFK (dropofflat,dropofflon);
from_Midtown=isinmidtown(pickuplat,pikcuplon);
to_Midtown=isinmidtown (dropofflat,dropofflon);

JFK_to_Midtown= from_JFK & to_Midtown;
Midtown_to_JFK= from_Midtown & to_JFK;
%% count trip/passenger numbers
n=length(pickuplat);
n_pc=nansum(passenger);
n_from_JFK=nnz(from_JFK);
n_to_JFK=nnz(to_JFK);
n_from_Midtown=nnz(from_Midtown);
n_to_Midtown=nnz(to_Midtown);
n_JFK_to_Midtown=nnz(JFK_to_Midtown);
n_Midtown_to_JFK=nnz(Midtown_to_JFK);
n_pc_from_JFK=nansum(passenger(from_JFK));
n_pc_to_JFK=nansum(passenger(to_JFK));
n_pc_from_Midtown=nansum(passenger(from_Midtown));
n_pc_to_Midtown=nansum(passenger(to_Midtown));
n_pc_JFK_to_Midtown=nansum(passenger(JFK_to_Midtown));
n_pc_Midtown_to_JFK=nansum(passenger(Midtown_to_JFK));
%% Report
fprintf('Total number of trips: %d\n',int64(n));

fprintf('Number of trips from JFK:%d \t Percentage: %f%% | to JFK: %d \t Percentage:%f%%\n',...
    int64(n_from_JFK),n_from_JFK/n*100,int64(n_to_JFK),n_to_JFK/n*100);
fprintf('Number of trips from Midtown:%d \t Percentage:%f%% | to Midtown: %d\t Percentage: %f%%\n',...
    int64(n_from_Midtown),n_from_Midtown/n*100,int64(n_to_Midtown), n_to_Midtown/n*100);

fprintf('Number of trips from JFK to Midtown: %d\t Percentage:%f %%\n',int64(n_JFK_to_Midtown),n_JFK_to_Midtown/n *100);
fprintf('Number of trips from Midtown to JFK: %d\t Percentage: %f %%\n',int64(n_Midtown_to_JFK),n_Midtown_to_JFK/n *100 );
% person trips
fprintf('\nTotal number of passengers: %d\n',int64(n_pc));

fprintf('Number of passengres from JFK:%d \t Percentage: %f%% | to JFK: %d \t Percentage:%f%%\n',...
    int64(n_pc_from_JFK),n_pc_from_JFK/n_pc*100,int64(n_pc_to_JFK),n_pc_to_JFK/n_pc*100);
fprintf('Number of passengers from Midtown:%d \t Percentage:%f%% | to Midtown: %d\t Percentage: %f%%\n',...
    int64(n_pc_from_Midtown),n_pc_from_Midtown/n_pc*100,int64(n_pc_to_Midtown), n_pc_to_Midtown/n_pc*100);

fprintf('Number of passengers from JFK to Midtown: %d\t Percentage:%f %%\n',...
    int64(n_pc_JFK_to_Midtown),n_pc_JFK_to_Midtown/n_pc *100);
fprintf('Number of passengers from Midtown to JFK: %d\t Percentage: %f %%\n',...
    int64(n_pc_Midtown_to_JFK),n_pc_Midtown_to_JFK/n_pc *100 );
end
