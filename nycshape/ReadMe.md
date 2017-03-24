# Generate Manhattan Boundary

The source file used to generate Manhattan.shp is nyct2010.shp, which is open to public at [NYC Census Blocks and Tracts shapefie]( https://www1.nyc.gov/site/planning/data-maps/open-data/districts-download-metadata.page)

Note that the Manhattan.shp is projected back to __WGS84__ from __NAD_1983_StatePlane_New_York_Long_Island_FIPS_3104_Feet__ , using QGIS's __reproject tool__.

The output __ManhattanBoundary.mat__ is used for clipping the taxi trip results within Manhattan.
