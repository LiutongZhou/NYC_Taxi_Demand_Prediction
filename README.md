## NYC_Taxi_Demand_Prediction

  Demand.mat is the Generated Demand Matrices
  
  Format: Matlab Binary file
  
  Geo Range: 
    
    Latitude Limits: [40.68, 40.887]
    
    Longitude Limits: [-74.0418, -73.899]
  
  Time Range: From 2016-01-01 00:00:00 to 2016-06-30 23:00:00
 
  Time Interval: 1 hour
  
  RasterSize: 23 by 12

  For Example:  A [23×12 double] matrix stamped by '2016-01-01 00:00:00' is the number of persons picked up in each cell

  load Demand will load the Demand table called Demand and the Georeference object named R

Demand
            time                 demand    
    _____________________    ______________

    '2016-01-01 00:00:00'    [23×12 double]
    '2016-01-01 01:00:00'    [23×12 double]
    '2016-01-01 02:00:00'    [23×12 double]
	...							...

