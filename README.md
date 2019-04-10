GeoSpark: Bring sf to spark
================

![](https://image-static.segmentfault.com/101/895/1018959988-5c9809116a126)

[![CRAN version](https://www.r-pkg.org/badges/version/geospark)](https://CRAN.R-project.org/package=geospark) [![Build Status](https://travis-ci.org/harryprince/geospark.svg?branch=master)](https://travis-ci.org/harryprince/geospark) [![]()](https://github.com/ropensci/software-review/issues/288)

Introduction & Philosophy
-------------------------

Goal: make traditional GISer handle geospatial big data easier.

The origin idea comes from [Uber](https://www.oreilly.com/ideas/query-the-planet-geospatial-big-data-analytics-at-uber), which proposed a ESRI Hive UDF + Presto solution to solve large-scale geospatial data processing problem with spatial index in production.

However, The Uber solution is not open source yet and Presto is not popular than Spark.

In that, `geospark` R package aims at bringing local [sf](https://github.com/r-spatial/sf) functions to distributed spark mode with [GeoSpark](https://github.com/DataSystemsLab/GeoSpark) scala package.

Currently, `geospark` support the most of important `sf` functions in spark, here is a [summary comparison](https://github.com/harryprince/geospark/blob/master/Reference.md). And the `geospark` R package is keeping close with geospatial and big data community, which powered by [sparklyr](https://spark.rstudio.com), [sf](https://github.com/r-spatial/sf), [dplyr](https://db.rstudio.com/dplyr/) and [dbplyr](https://github.com/tidyverse/dbplyr).

Installation
------------

This package requires Apache Spark 2.X which you can install using `sparklyr::install_spark("2.4")`; in addition, you can install `geospark` as follows:

``` r
pak::pkg_install("harryprince/geospark")
```

Getting Started
---------------

In this example we will join spatial data using quadrad tree indexing. First, we will initialize the `geospark` extension and connect to Spark using `sparklyr`:

``` r
library(sparklyr)
library(geospark)

conf <- spark_config()
sc <- spark_connect(master = "local", config = conf)
register_gis(sc)
```

Next we will load some spatial dataset containing as polygons and points.

``` r
polygons <- read.table(system.file(package="geospark","examples/polygons.txt"), sep="|", col.names=c("area","geom"))
points <- read.table(system.file(package="geospark","examples/points.txt"), sep="|", col.names=c("city","state","geom"))

polygons_wkt <- copy_to(sc, polygons)
points_wkt <- copy_to(sc, points)
```

And we can quickly visulize the dataset by `mapview` and `sf`.

    M1 = polygons %>%
    sf::st_as_sf(wkt="geom") %>% mapview::mapview()


    M2 = points %>%
    sf::st_as_sf(wkt="geom") %>% mapview::mapview()

    M1+M2

![](https://segmentfault.com/img/bVbqmP9/view?w=1198&h=766)

### The Spark GIS SQL Mode

Now we can perform a GeoSpatial join using the `st_contains` which converts `wkt` into geometry object with 4326 `crs` which means a `wgs84` projection. To get the original data from `wkt` format, we will use the `st_geomfromwkt` functions. We can execute this spatial query using `DBI`:

``` r
DBI::dbGetQuery(sc, "
  SELECT area, state, count(*) cnt FROM
    (SELECT area, ST_GeomFromWKT(polygons.geom ) as y FROM polygons) polygons
  INNER JOIN
    (SELECT ST_GeomFromWKT (points.geom) as x, state, city FROM points) points
  WHERE ST_Contains(polygons.y,points.x) GROUP BY area, state")
```

                 area state cnt
    1      texas area    TX  10
    2     dakota area    SD   1
    3     dakota area    ND  10
    4 california area    CA  10
    5   new york area    NY   9

### The Tidyverse Mode

You can also perform this query using `dplyr 0.9` installed through:

``` r
remotes::install_github("tidyverse/dplyr")
remotes::install_github("tidyverse/dbplyr")
```

Then, you can join as follows:

``` r
library(dplyr)
polygons_wkt <- mutate(polygons_wkt, y = st_geomfromwkt(geom))
points_wkt <- mutate(points_wkt, x = st_geomfromwkt(geom))

sc_res = inner_join(polygons_wkt, points_wkt, by = sql("st_contains(y, x)")) %>%
  group_by(area, state) %>%
  summarise(cnt = n())
  
sc_res %>%
  head()
```

        # Source: spark<?> [?? x 3]
        # Groups: area
          area            state   cnt
          <chr>           <chr> <dbl>
        1 texas area      TX       10
        2 dakota area     SD        1
        3 dakota area     ND       10
        4 california area CA       10
        5 new york area   NY        9

The final result can be present by `leaflet`.

    Idx_df = collect(sc_res) %>% 
    right_join(polygons,by = (c("area"="area"))) %>% 
    sf::st_as_sf(wkt="geom")

    Idx_df %>% 
    leaflet::leaflet() %>% 
    leaflet::addTiles() %>% 
    leaflet::addPolygons(popup = ~as.character(cnt),color=~colormap::colormap_pal()(cnt)) 

![](https://image-static.segmentfault.com/305/306/3053068814-5c9803c8d59a7)

Finally, we can disconnect:

``` r
spark_disconnect_all()
```

Performance
-----------

### Configuration

To improve performance, it is recommended to use the `KryoSerializer` and the `GeoSparkKryoRegistrator` before connecting as follows:

``` r
conf <- spark_config()
conf$spark.serializer <- "org.apache.spark.serializer.KryoSerializer"
conf$spark.kryo.registrator <- "org.datasyslab.geospark.serde.GeoSparkKryoRegistrator"
```

### Benchmarks

This performance comparison is an extract from the original [GeoSpark: A Cluster Computing Framework for Processing Spatial Data](https://pdfs.semanticscholar.org/347d/992ceec645a28f4e7e45e9ab902cd75ecd92.pdf) paper:

<table>
<colgroup>
<col width="2%" />
<col width="86%" />
<col width="11%" />
</colgroup>
<thead>
<tr class="header">
<th>No.</th>
<th>test case</th>
<th>the number of records</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>1</td>
<td>SELECT IDCODE FROM zhenlongxiang WHERE ST_Disjoint(geom,ST_GeomFromText(‘POLYGON((517000 1520000,619000 1520000,619000 2530000,517000 2530000,517000 1520000))’));</td>
<td>85,236 rows</td>
</tr>
<tr class="even">
<td>2</td>
<td>SELECT fid FROM cyclonepoint WHERE ST_Disjoint(geom,ST_GeomFromText(‘POLYGON((90 3,170 3,170 55,90 55,90 3))’,4326))</td>
<td>60,591 rows</td>
</tr>
</tbody>
</table>

Query performance(ms),

| No. | PostGIS/PostgreSQL | GeoSpark SQL | ESRI Spatial Framework for Hadoop |
|-----|--------------------|--------------|-----------------------------------|
| 1   | 9631               | 480          | 40,784                            |
| 2   | 110872             | 394          | 64,217                            |

According to this papaer, the Geospark SQL definitely outperforms PG and ESRI UDF under a very large data set.

If you are wondering how the spatial index accelerate the query process, here is a good Uber example: [Unwinding Uber’s Most Efficient Service](https://medium.com/@buckhx/unwinding-uber-s-most-efficient-service-406413c5871d#.dg5v6irao) and the [Chinese translation version](https://segmentfault.com/a/1190000008657566)

Functions
---------

### Constructor

<table style="width:11%;">
<colgroup>
<col width="5%" />
<col width="5%" />
</colgroup>
<thead>
<tr class="header">
<th>name</th>
<th>desc</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>ST_GeomFromWKT</code></td>
<td>Construct a Geometry from Wkt.</td>
</tr>
<tr class="even">
<td><code>ST_GeomFromWKB</code></td>
<td>Construct a Geometry from Wkb.</td>
</tr>
<tr class="odd">
<td><code>ST_GeomFromGeoJSON</code></td>
<td>Construct a Geometry from GeoJSON.</td>
</tr>
<tr class="even">
<td><code>ST_Point</code></td>
<td>Construct a Point from X and Y.</td>
</tr>
<tr class="odd">
<td><code>ST_PointFromText</code></td>
<td>Construct a Point from Text, delimited by Delimiter.</td>
</tr>
<tr class="even">
<td><code>ST_PolygonFromText</code></td>
<td>Construct a Polygon from Text, delimited by Delimiter.</td>
</tr>
<tr class="odd">
<td><code>ST_LineStringFromText</code></td>
<td>Construct a LineString from Text, delimited by Delimiter.</td>
</tr>
<tr class="even">
<td><code>ST_PolygonFromEnvelope</code></td>
<td>Construct a Polygon from MinX, MinY, MaxX, MaxY.</td>
</tr>
</tbody>
</table>

### Geometry Measurement

| name          | desc                                          |
|---------------|-----------------------------------------------|
| `ST_Length`   | Return the perimeter of A                     |
| `ST_Area`     | Return the area of A                          |
| `ST_Distance` | Return the Euclidean distance between A and B |

### Spatial Join

![](https://camo.githubusercontent.com/f18513c8002df02bdb6e3aac451519beb3c87ebb/68747470733a2f2f7365676d656e746661756c742e636f6d2f696d672f625662714665333f773d3132383026683d353038)

| name            | desc |
|-----------------|------|
| `ST_Contains`   |      |
| `ST_Intersects` |      |
| `ST_Within`     |      |
| `ST_Equals`     |      |
| `ST_Crosses`    |      |
| `ST_Touches`    |      |
| `ST_Overlaps`   |      |

### Distance join

`ST_Distance`:

Spark GIS SQL mode example:

    SELECT *
    FROM pointdf1, pointdf2
    WHERE ST_Distance(pointdf1.pointshape1,pointdf2.pointshape2) <= 2

Tidyverse style example:

    inner_join(x = pointdf1,
               y = pointdf2,
               by = sql("ST_Distance(pointshape1, pointshape2) <= 2"))

### Aggregation

<table style="width:11%;">
<colgroup>
<col width="5%" />
<col width="5%" />
</colgroup>
<thead>
<tr class="header">
<th>name</th>
<th>desc</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>ST_Envelope_Aggr</code></td>
<td>Return the entire envelope boundary of all geometries in A</td>
</tr>
<tr class="even">
<td><code>ST_Union_Aggr</code></td>
<td>Return the polygon union of all polygons in A</td>
</tr>
</tbody>
</table>

### More Advacned Functions

<table style="width:11%;">
<colgroup>
<col width="5%" />
<col width="5%" />
</colgroup>
<thead>
<tr class="header">
<th>name</th>
<th>desc</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>ST_ConvexHull</code></td>
<td>Return the Convex Hull of polgyon A</td>
</tr>
<tr class="even">
<td><code>ST_Envelope</code></td>
<td>Return the envelop boundary of A</td>
</tr>
<tr class="odd">
<td><code>ST_Centroid</code></td>
<td>Return the centroid point of A</td>
</tr>
<tr class="even">
<td><code>ST_Transform</code></td>
<td>Transform the Spatial Reference System / Coordinate Reference System of A, from SourceCRS to TargetCRS</td>
</tr>
<tr class="odd">
<td><code>ST_IsValid</code></td>
<td>Test if a geometry is well formed</td>
</tr>
<tr class="even">
<td><code>ST_PrecisionReduce</code></td>
<td>Reduce the decimals places in the coordinates of the geometry to the given number of decimal places. The last decimal place will be rounded.</td>
</tr>
<tr class="odd">
<td><code>ST_IsSimple</code></td>
<td>Test if geometry's only self-intersections are at boundary points.</td>
</tr>
<tr class="even">
<td><code>ST_Buffer</code></td>
<td>Returns a geometry/geography that represents all points whose distance from this Geometry/geography is less than or equal to distance.</td>
</tr>
<tr class="odd">
<td><code>ST_AsText</code></td>
<td>Return the Well-Known Text string representation of a geometry</td>
</tr>
</tbody>
</table>

Architecture
------------

![](https://user-images.githubusercontent.com/5362577/53225664-bf6abc80-36b3-11e9-8b8e-41611fc7098e.png)
========================================================================================================
