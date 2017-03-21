## NYC Taxi Demand Prediction

Updated on 2017-03-21: HDF5 and Holiday data uploaded to [onedrive](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?folderid=1e27ef8057af4432fbc2d940480dd482d&authkey=AYgG5cth5d2MJGG8LNFQ2qQ)

### Source of Raw Data

1. Weather: https://www.ncdc.noaa.gov/qclcd/QCLCD
2. NYC Taxi: http://www1.nyc.gov/html/tlc/html/about/trip_record_data.shtml

### [Generated Data](https://facilities-my.sharepoint.com/personal/lz2484_columbia_edu/_layouts/15/guestaccess.aspx?folderid=1e27ef8057af4432fbc2d940480dd482d&authkey=AYgG5cth5d2MJGG8LNFQ2qQ)

The data is generated using 6 months' raw yellow taxi data from 2016-01-01 to 2016-06-30. For now, the 6 months' raw data has a size of 10 GB. The data generation process (designed and implemented in a Mapreduce workflow) takes 3.5 hours. Processing one year's data is expected to take 7 hours. This process could be done on a cluster (need to contact Columbia HPC) using the same code.

Demand.mat: the Generated Data stored in the format of Matlab Binary File. It contains two variables: a time table 'Demand' and a Georeference object 'R'. 

R: a Georeference object which gives geo information such as geo range
 ```
 R=
             Latitude Limits: [40.6769, 40.8868]
            Longitude Limits: [-74.0411, -73.9073]
                 Raster Size: [29, 14]
       Raster Interpretation: Rectangular Cells
           Columns StartFrom: 'south'
              Rows StartFrom: 'west'
Cell Edge Length In Latitude: 0.00723660362598688
    Edge Length In Longitude: 0.00955245263273959
      Coordinate System Type: 'WGS84'
                        Unit: 'degree'
                        ...
 ```
 
Demand: a time table covering the time range: From 2016-01-01 00:00:00 to 2016-06-30 23:00:00. Time Interval: 1 hour

 ```
 Demand = 

            time                demand     
    ___________________    ________________

    2016-01-01 00:00:00    [29×14×2 double]
    2016-01-01 01:00:00    [29×14×2 double]
    ...                    ...
 ```
 
For example: Demand.demand{1}(:,:,1) is a [29×14 double] matrix corresponding to Demand.time(1):2016-01-01 00:00:00. It is the number of persons who are picked up in each rectangular cell within Manhattan counted from 2016-01-01 00:00:00 till 2016-01-01 00:59:59.

demand.h5: the same data rearranged and stored in hdf5 format. 
  





