# data import
bq mk --time_partitioning_type=DAY NYCTaxi.yellow

bq load --replace --source_format=CSV --skip_leading_rows=1 \
--schema VendorID:INTEGER,pickup_datetime:TIMESTAMP,dropoff_datetime:TIMESTAMP,passenger_count:INTEGER,trip_distance:FLOAT,pickup_longitude:FLOAT,pickup_latitude:FLOAT,RatecodeID:INTEGER,store_and_fwd_flag:BOOLEAN,dropoff_longitude:FLOAT,dropoff_latitude:FLOAT,payment_type:INTEGER,fare_amount:FLOAT,extra:FLOAT,mta_tax:FLOAT,tip_amount:FLOAT,tolls_amount:FLOAT,improvement_surcharge:FLOAT,total_amount:FLOAT \
'NYCTaxi.yellow$20160101' gs://nyc_taxi_trip/yellow_tripdata_2016-01.csv

bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20160201' gs://nyc_taxi_trip/yellow_tripdata_2016-02.csv
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20160301' gs://nyc_taxi_trip/yellow_tripdata_2016-03.csv
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20160401' gs://nyc_taxi_trip/yellow_tripdata_2016-04.csv
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20160501' gs://nyc_taxi_trip/yellow_tripdata_2016-05.csv
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20160601' gs://nyc_taxi_trip/yellow_tripdata_2016-06.csv 
#
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20150701' gs://nyc_taxi_trip/yellow_tripdata_2015-07.csv 
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20150801' gs://nyc_taxi_trip/yellow_tripdata_2015-08.csv 
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20150901' gs://nyc_taxi_trip/yellow_tripdata_2015-09.csv 
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20151001' gs://nyc_taxi_trip/yellow_tripdata_2015-10.csv 
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20151101' gs://nyc_taxi_trip/yellow_tripdata_2015-11.csv 
bq --nosync load --source_format=CSV --skip_leading_rows=1 'NYCTaxi.yellow$20151201' gs://nyc_taxi_trip/yellow_tripdata_2015-12.csv 
bq ls -j -n 12

# data stats
bq query --replace --destination_table 'NYCTaxi.stat' \
'SELECT
  DAYOFWEEK(pickup_datetime )=1 || DAYOFWEEK(pickup_datetime )=7 AS isweekend,  HOUR(pickup_datetime ) AS hours,
  NTH(2501,QUANTILES(trip_distance,10001)) AS trip_q1,  NTH(7501,QUANTILES(trip_distance,10001)) AS trip_q3,
  NTH(9751,QUANTILES(trip_distance,10001)) AS trip_quantile97_5,  NTH(251,QUANTILES(trip_distance,10001)) AS trip_quantile2_5,
  AVG(trip_distance) AS trip_mean,  NTH(5001,QUANTILES(trip_distance,10001)) AS trip_median,  STDDEV(trip_distance) AS trip_std,
  #
  NTH(2501,QUANTILES(duration,10001)) AS duration_q1,  NTH(7501,QUANTILES(duration ,10001)) AS duration_q3,
  NTH(9751,QUANTILES(duration ,10001)) AS duration_quantile97_5,  NTH(251,QUANTILES(duration ,10001)) AS duration_quantile2_5,
  AVG(duration) AS duration_mean,  NTH(5001,QUANTILES(duration,10001)) AS duration_median,  STDDEV(duration) AS duration_std,
  #
  NTH(2501,QUANTILES(trip_distance /(duration/60),10001)) AS speed_q1,  NTH(7501,QUANTILES(trip_distance /(duration/60) ,10001)) AS speed_q3,
  NTH(9751,QUANTILES(trip_distance /(duration/60) ,10001)) AS speed_quantile97_5,  NTH(251,QUANTILES(trip_distance /(duration/60) ,10001)) AS speed_quantile2_5,
  AVG(trip_distance /(duration/60)) AS speed_mean,  NTH(5001,QUANTILES(trip_distance /(duration/60),10001)) AS speed_median,
  STDDEV(trip_distance /(duration/60)) AS speed_std,
  #
  sum(passenger_count) as pickups
  #
FROM
  NYCTaxi.cleanyellow
GROUP BY
  isweekend,
  hours
ORDER BY
  isweekend,
  hours;'

# data filtering
#filter:
#longitude: -74.036206,-73.909863
#latitude: 40.680276,40.882530
#trip_distance: 0~20 miles,
#fare:1~105 usd
#passenger_count<=6
# duration:2min~120 min
#straight_line_dist:0~15 mile 
# trip_distance/straight_line_dist: 0.95~6 #note that if winding factor <1, it violates euclidean distance limit. if it is too large, the track is not reasonable
# speed: walking speed ~ speed limit: 3.1~55 (mph)
# fare rate:  Fare/Distance: 2~10  
bq query --replace --destination_table 'NYCTaxi.cleanyellow' --allow_large_results \
'SELECT
  pickup_datetime,
  dropoff_datetime,
  pickup_longitude,
  pickup_latitude,
  dropoff_longitude,
  dropoff_latitude,
  passenger_count,
  trip_distance,
  VendorID,
  payment_type,
  fare_amount,
  total_amount,
  #duration in minutes
  (TIMESTAMP_TO_SEC(dropoff_datetime)-TIMESTAMP_TO_SEC(pickup_datetime))/60 AS duration,
  #In NYC:
  #1 degree lat ~= 69.1703234284 miles
  #1 degree lon ~= 52.3831781372 miles
  #The magic numbers are the squares of these values
  SQRT( (4784.533643189461*POW((dropoff_latitude-pickup_latitude),2) + 2743.9973517536278*POW((dropoff_longitude-pickup_longitude),2))) AS straight_line_dist
FROM
  NYCTaxi.yellow
WHERE
  (pickup_longitude BETWEEN -74.036206  AND -73.909863)
  AND (pickup_latitude BETWEEN 40.680276  AND 40.882530)
  AND (trip_distance BETWEEN 0.001  AND 20 )
  AND (total_amount BETWEEN 1  AND 105 )
  AND passenger_count<=6
  and (fare_amount/trip_distance BETWEEN 2 AND 12)
HAVING
  (duration BETWEEN 2  AND 120)
  AND (straight_line_dist BETWEEN 0.001  AND 15)
  AND (trip_distance/straight_line_dist BETWEEN 0.95 and 6)
  # Speed:= trip_distance/(duration/60) in miles/h
  AND (trip_distance/(duration/60) BETWEEN 3.1  AND 55 ) ;
  '

  # exporting clean data to cloud storage
  bq extract --compression=GZIP \
  'traffic-demand-predict:NYCTaxi.cleanyellow' \
  gs://nyc_taxi_trip/cleanyellow/cleanyellow_*.zip

  # To Download data, uncomment the following
  #  gsutil -m cp -r gs://nyc_taxi_trip/cleanyellow S:\DataBackup\cleanyellow
  # 
  #   
bq query --replace --destination_table 'NYCTaxi.cleanyellow201407_201512' --allow_large_results \
'SELECT
  pickup_datetime,
  dropoff_datetime,
  pickup_longitude,
  pickup_latitude,
  dropoff_longitude,
  dropoff_latitude,
  passenger_count,
  trip_distance,
  vendor_iD,
  payment_type,
  fare_amount,
  total_amount,
  #duration in minutes
  (TIMESTAMP_TO_SEC(dropoff_datetime)-TIMESTAMP_TO_SEC(pickup_datetime))/60 AS duration,
  #In NYC:
  #1 degree lat ~= 69.1703234284 miles
  #1 degree lon ~= 52.3831781372 miles
  #The magic numbers are the squares of these values
  SQRT( (4784.533643189461*POW((dropoff_latitude-pickup_latitude),2) + 2743.9973517536278*POW((dropoff_longitude-pickup_longitude),2))) AS straight_line_dist
FROM
  [nyc-tlc:yellow.trips]
WHERE
  pickup_datetime BETWEEN TIMESTAMP("2014-07-01 00:00:00") and TIMESTAMP("2015-12-31 23:59:59")
  and (pickup_longitude BETWEEN -74.036206  AND -73.909863)
  AND (pickup_latitude BETWEEN 40.680276  AND 40.882530)
  AND (trip_distance BETWEEN 0.001  AND 20 )
  AND (total_amount BETWEEN 1  AND 105 )
  AND passenger_count<=6
  and (fare_amount/trip_distance BETWEEN 2 AND 12)
HAVING
  (duration BETWEEN 2  AND 120)
  AND (straight_line_dist BETWEEN 0.001  AND 15)
  AND (trip_distance/straight_line_dist BETWEEN 0.95 and 6)
  # Speed:= trip_distance/(duration/60) in miles/h
  AND (trip_distance/(duration/60) BETWEEN 3.1  AND 55 ) ;
  '

  bq extract --compression=GZIP \
  'traffic-demand-predict:NYCTaxi.cleanyellow201407_201512' \
  gs://nyc_taxi_trip/cleanyellow201407_201512/cleanyellow_*.zip