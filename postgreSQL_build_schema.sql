create database NYCTaxi;
CREATE EXTENSION postgis;

CREATE TABLE clean_yellow (
  id serial primary key,
  pickup_datetime timestamp without time zone,
  dropoff_datetime timestamp without time zone,
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
  duration,
  straight_line_dist
);
/*
N.B. junk columns are there because some tripdata file headers are
inconsistent with the actual data, e.g. header says 20 or 21 columns per row,
but data actually has 22 or 23 columns per row, which COPY doesn't like.
junk1 and junk2 should always be null
*/


CREATE UNIQUE INDEX index_fhv_bases_on_base_number ON tabel (column);
CREATE INDEX index_fhv_bases_on_dba_category ON fhv_bases (dba_category);

CREATE TABLE cab_types (
  id serial primary key,
  type varchar
);

INSERT INTO cab_types (type) SELECT 'yellow';
INSERT INTO cab_types (type) SELECT 'green';
INSERT INTO cab_types (type) SELECT 'uber';

CREATE TABLE trips (
  id serial primary key,
  cab_type_id integer,
  vendor_id varchar,
  pickup_datetime timestamp without time zone,
  dropoff_datetime timestamp without time zone,
  store_and_fwd_flag char(1),
  rate_code_id integer,
  pickup_longitude numeric,
  pickup_latitude numeric,
  dropoff_longitude numeric,
  dropoff_latitude numeric,
  passenger_count integer,
  trip_distance numeric,
  fare_amount numeric,
  extra numeric,
  mta_tax numeric,
  tip_amount numeric,
  tolls_amount numeric,
  ehail_fee numeric,
  improvement_surcharge numeric,
  total_amount numeric,
  payment_type varchar,
  trip_type integer,
  pickup_nyct2010_gid integer,
  dropoff_nyct2010_gid integer,
  pickup_location_id integer,
  dropoff_location_id integer
);

SELECT AddGeometryColumn('trips', 'pickup', 4326, 'POINT', 2);
SELECT AddGeometryColumn('trips', 'dropoff', 4326, 'POINT', 2);

CREATE TABLE central_park_weather_observations (
  station_id varchar,
  station_name varchar,
  date date,
  precipitation numeric,
  snow_depth numeric,
  snowfall numeric,
  max_temperature numeric,
  min_temperature numeric,
  average_wind_speed numeric
);

CREATE UNIQUE INDEX index_weather_observations ON central_park_weather_observations (date);