## NYC Taxi Demand Prediction
> Updated on 2017-04-29: New data (demand.h5, holiday.txt,...) uplaoded to [onedrive](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?guestaccesstoken=xtFRGmTKIG7C3qwO5pdbnqfQkP2p4jZe8bbNXpoErdY%3d&folderid=2_1e27ef8057af4432fbc2d940480dd482d&rev=1)

> Updated on 2017-04-12: Weather data (Meteorology.h5) uploaded to [onedrive](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?guestaccesstoken=xtFRGmTKIG7C3qwO5pdbnqfQkP2p4jZe8bbNXpoErdY%3d&folderid=2_1e27ef8057af4432fbc2d940480dd482d&rev=1)

> The **[draft](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?guestaccesstoken=LHqXGo868BaVSvQXMzDYNbuNIJx%2fNkGBXleUPUp2OwQ%3d&docid=2_134225cf561184cdb99fcac96a455a106&rev=1)** is constantly being updated on onedrive. 

> Updated on 2017-03-21: HDF5 and Holiday data uploaded to [onedrive](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?guestaccesstoken=xtFRGmTKIG7C3qwO5pdbnqfQkP2p4jZe8bbNXpoErdY%3d&folderid=2_1e27ef8057af4432fbc2d940480dd482d&rev=1)

### Source of Raw Data

1. Weather: https://www.ncdc.noaa.gov/qclcd/QCLCD. A batch order is available through https://www.ncdc.noaa.gov/cdo-web/datasets
2. NYC Taxi: http://www1.nyc.gov/html/tlc/html/about/trip_record_data.shtml

### [Generated Data](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?guestaccesstoken=xtFRGmTKIG7C3qwO5pdbnqfQkP2p4jZe8bbNXpoErdY%3d&folderid=2_1e27ef8057af4432fbc2d940480dd482d&rev=1)

The generated data is derived using 2 years' raw yellow taxi data (from 2014-07-01 to 2016-06-30). ~~For now, we used only 6 months' raw data with a total size of 10 GB~~. The data generation process (designed and implemented in a Mapreduce workflow) takes 2.5 hours (for processing two years' data). This process could be done on a cluster (need to contact Columbia HPC) using the same code.
____
**Demand.mat**: the Generated Data stored in the format of Matlab Binary File. It contains two variables: a time table 'Demand' and a Georeference object 'R'. 

R: a Georeference object which gives geo information such as geo range
 ```
 R=
             Latitude Limits: [40.6769, 40.8868]
            Longitude Limits: [-74.0411, -73.9073]
                 Raster Size: [32, 32]
       Raster Interpretation: Rectangular Cells
           Columns StartFrom: 'north'
              Rows StartFrom: 'west'
Cell Edge Length In Latitude: 0.00723660362598688
    Edge Length In Longitude: 0.00955245263273959
      Coordinate System Type: 'WGS84'
                        Unit: 'degree'
                        ...
 ```
 
Demand: a time table ranging from 2014-07-01 00:00:00 to 2016-06-30 23:00:00 with an interval of 1 hour

 ```
 Demand = 

            time                demand     
    ___________________    ________________

    2016-01-01 00:00:00    [32×32×2 double]
    2016-01-01 01:00:00    [32×32×2 double]
    ...                    ...
 ```
 
For example: `Demand.demand{1}(:,:,1)` is a [32×32 double] matrix corresponding to `Demand.time(1)`:2014-07-01 00:00:00. It is the number of persons who are picked up in each rectangular cell within Manhattan (defined by Manhattan Boundary) counted from 2014-07-01 00:00:00 till 2014-07-01 00:59:59. Similarly, `Demand.demand{1}(:,:,2)` is the number of persons dropped within Manhattan during the same period of time.
____
**demand.h5**: the same data rearranged and stored in hdf5 format. It contains two datasets: 'demand_tensor' and 'datetime'

demand_tensor: a 32x32x2x4369 double 4-D tenor. The last dimension corresponds to time. demand_tensor[:][:][0][i] is the pickup matrix at time datetime[i];

datetime: a 4369x1 string timestampe.

  





