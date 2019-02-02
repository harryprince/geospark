## PostGIS vs ESRI UDF vs SF vs Geospark

### Geometry Constructure

postgis|esri udf|sf|geospark|function| definition
---|---|---|---|---|---
partial|partial|yes|no|st_cast| Convert the geometry type from one to another
yes|yes|yes|yes|ST_GeomFromText | Return a specified ST_Geometry value from Well-Known Text representation (WKT).
yes|yes|no|no|ST_MakeBox2D | Creates a BOX2D defined by the given point geometries.
yes|yes|yes|yes|ST_Point | Returns an ST_Point with the given coordinate values. OGC alias for ST_MakePoint.
yes|no|no|no|ST_PointFromGeoHash | Return a point from a GeoHash string.
yes|yes|yes|yes|ST_Polygon | Returns a polygon built from the specified linestring and SRID.


### Geometry Measurement

## Geometry Operations

## References

* https://postgis.net/docs/reference.html
* https://github.com/rstudio/cheatsheets/raw/master/sf.pdf


