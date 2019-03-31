## PostGIS vs ESRI UDF vs SF vs Geospark

### Geometry Constructure

Complex geometries / trajectories: point, polygon, linestring, multi-point, multi-polygon, multi-linestring, GeometryCollection

postgis|esri udf|sf|geospark|function| definition
---|---|---|---|---|---
partial|partial|yes|no|st_cast| Convert the geometry type from one to another
yes|yes|yes|yes|ST_GeomFromText | Return a specified ST_Geometry value from Well-Known Text representation (WKT).
yes|yes|no|no|ST_MakeBox2D | Creates a BOX2D defined by the given point geometries.
yes|yes|yes|yes|ST_Point | Returns an ST_Point with the given coordinate values. OGC alias for ST_MakePoint.
yes|no|no|no|ST_PointFromGeoHash | Return a point from a GeoHash string.
yes|yes|yes|yes|ST_Polygon | Returns a polygon built from the specified linestring and SRID.
yes|yes|yes|yes|ST_Transform| Coordinate Reference System / Spatial Reference System Transformation: for exmaple, from WGS84 (EPSG:4326, degree-based), to EPSG:3857 (meter-based)

### Geometry Relation

![](https://segmentfault.com/img/bVbqFe3?w=1280&h=508)

### Data IO

CSV, TSV, WKT, WKB, GeoJSON, NASA NetCDF/HDF, Shapefile (.shp, .shx, .dbf)

### Spatial Query

range query, range join query, distance join query, K Nearest Neighbor query

### Spatial Index

R-Tree, Quad-Tree

### Spatial partitioning

KDB-Tree, Quad-Tree, R-Tree, Voronoi diagram, Hilbert curve, Uniform grids

### Geometry Measurement

st_area, st_length

## Geometry Operations

## References

* [POSTGIS ST_* REFERENCE](https://postgis.net/docs/reference.html)
* [ESRI UDF ST_* REFERENCE](https://github.com/Esri/spatial-framework-for-hadoop/wiki/UDF-Documentation)
* [R SF ST_* REFERENCE](https://github.com/rstudio/cheatsheets/raw/master/sf.pdf)
* [GeoSpark ST_* REFERENCE](https://datasystemslab.github.io/GeoSpark/api/sql/GeoSparkSQL-Constructor/)


