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


# data stats
bq query --replace --destination_table 'NYCTaxi.stat' \
'SELECT
  MIN(trip_distance) AS trip_min,
  MAX(trip_distance) AS trip_max,
  NTH(2501,QUANTILES(trip_distance,10001)) AS trip_q1,
  NTH(7501,QUANTILES(trip_distance,10001)) AS trip_q3,
  NTH(9976,QUANTILES(trip_distance,10001)) AS trip_quantile99_75,
  NTH(9991,QUANTILES(trip_distance,10001)) AS trip_quantile99_9,
  AVG(trip_distance) AS trip_mean,
  STDDEV(trip_distance) AS trip_std,
  MIN(total_amount) AS fare_min,
  MAX(total_amount) AS fare_max,
  NTH(2501,QUANTILES(total_amount,10001)) AS fare_q1,
  NTH(7501,QUANTILES(total_amount,10001)) AS fare_q3,
  NTH(9976,QUANTILES(total_amount,10001)) AS fare_quantile99_75,
  NTH(9991,QUANTILES(total_amount,10001)) AS fare_quantile99_9,
  AVG(total_amount) AS fare_mean,
  STDDEV(total_amount) AS fare_std,
  MIN(passenger_count) AS pc_min,
  MAX(passenger_count) AS pc_max,
  COUNT(*) AS row_count
FROM
  NYCTaxi.yellow
WHERE
  trip_distance>0
  AND total_amount>0
  AND passenger_count>0
  AND pickup_longitude>-74.255  AND pickup_longitude<-73.702
  AND pickup_latitude>40.4963  AND pickup_latitude<40.9161;'

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
  RatecodeID,
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
  pickup_longitude>-74.036206  AND pickup_longitude<-73.909863
  AND pickup_latitude>40.680276  AND pickup_latitude<40.882530
  AND trip_distance>0.001  AND trip_distance<20
  AND total_amount>1  AND total_amount<105
  AND passenger_count<=6
HAVING
  duration>2  AND duration<120
  AND straight_line_dist>0.001  AND straight_line_dist<15
  AND trip_distance/straight_line_dist>0.95   and trip_distance/straight_line_dist<6
  # Speed:= trip_distance/(duration/60) in miles/h
  AND trip_distance/(duration/60)>3.1  AND trip_distance/(duration/60)<55 ;
  '

  # exporting clean data to cloud storage
  bq extract --compression=GZIP \
  'traffic-demand-predict:NYCTaxi.cleanyellow' \
  gs://nyc_taxi_trip/cleanyellow/cleanyellow_*.zip
