gcloud config set project traffic-demand-predict
bq mk Weather
bq mk Weather.raw
bq --use_legacy_sql=false load --replace --source_format=CSV --skip_leading_rows=1 \
--schema schema.json Weather.raw gs://nyc_taxi_trip/Weather/Weather_NYC_CentralPark_2009_2017.csv 
