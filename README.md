## NYC Taxi Demand Prediction

Updated on 2017-03-21: HDF5 and Holiday data uploaded to [onedrive](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?folderid=1e27ef8057af4432fbc2d940480dd482d&authkey=AYgG5cth5d2MJGG8LNFQ2qQ)

### Source of Raw Data

1. Weather: https://www.ncdc.noaa.gov/qclcd/QCLCD
2. NYC Taxi: http://www1.nyc.gov/html/tlc/html/about/trip_record_data.shtml

### Generated Data

Demand.mat: the Generated Data. 

Format: Matlab Binary file. 

demand.h5: the same data rearranged and stored in hdf5 format. 

Geo Range: 
  
    Latitude Limits: [40.68, 40.887]
    Longitude Limits: [-74.0418, -73.899]
  
Time Range: From 2016-01-01 00:00:00 to 2016-06-30 23:00:00
 
Time Interval: 1 hour
  
RasterSize: 23 by 12

`load Demand` to load data, will load the time table 'Demand' and the Georeference object 'R'

Demand.demand{i}: a 23×12×2 array timestamped by Demand.time(i): (eg. '2016-01-01 00:00:00'), where `Demand.demand{i}(:,:,1)` is the number of pickups and `Demand.demand{i}(:,:,2)` is the number of dropoffs. 

For example: 
Demand.demand{i}(:,:,1) is a [23×12 double] matrix stamped by Demand.time(1): '2016-01-01 00:00:00'. It is the number of persons picked up in each cell from 00:00:00 till 00:59:59 on 2016-01-01.
