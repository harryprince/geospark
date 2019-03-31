---
title: "GeoSpark: Bring sf to spark"
output:
  github_document:
    fig_width: 9
    fig_height: 5
---

![](https://image-static.segmentfault.com/101/895/1018959988-5c9809116a126)

[![CRAN version](https://www.r-pkg.org/badges/version/geospark)](https://CRAN.R-project.org/package=geospark)
[![Build Status](https://travis-ci.org/harryprince/geospark.svg?branch=master)](https://travis-ci.org/harryprince/geospark)
[![]()](https://github.com/ropensci/software-review/issues/288)

## Introduction & Philosophy

The origin idea comes from [Uber](https://www.oreilly.com/ideas/query-the-planet-geospatial-big-data-analytics-at-uber), which proposed a ESRI Hive UDF + Presto solution to solve large-scale geospatial data processing problem in production.

However, The Uber solution is not open source yet and Presto is not popular than Spark.

In that, `geospark` R package aims at bringing local [sf](https://github.com/r-spatial/sf) functions to distributed spark mode with [GeoSpark](https://github.com/DataSystemsLab/GeoSpark) scala package.

Currently, `geospark` support most of important `sf` functions in spark,
here is a [summary
comparison](https://github.com/harryprince/geospark/blob/master/Reference.md).

## Installation

This package requires Apache Spark 2.X which you can install using
`sparklyr::install_spark("2.4")`; in addition, you can install
`geospark` as follows:

``` r
pak::pkg_install("harryprince/geospark")
```

## Getting Started

In this example we will join spatial data using quadrad tree indexing.
First, we will initialize the `geospark` extension and connect to Spark
using `sparklyr`:

``` r
library(sparklyr)
library(geospark)

conf <- spark_config()
sc <- spark_connect(master = "local", config = conf)
```

Next we will load some spatial dataset containing as polygons and
points.

``` r
polygons <- read.table(system.file(package="geospark","examples/polygons.txt"), sep="|", col.names=c("area","geom"))
points <- read.table(system.file(package="geospark","examples/points.txt"), sep="|", col.names=c("city","state","geom"))

polygons_wkt <- copy_to(sc, polygons)
points_wkt <- copy_to(sc, points)
```

And we can quickly visulize the dataset by `mapview` and `sf`.

```
M1 = polygons %>%
sf::st_as_sf(wkt="geom") %>% mapview::mapview()


M2 = points %>%
sf::st_as_sf(wkt="geom") %>% mapview::mapview()

M1+M2

```

![](https://segmentfault.com/img/bVbqmP9/view?w=1198&h=766)


Now we can perform a GeoSpatial join using the `st_contains` which
converts `wkt` into geometry object with 4326 `crs` which means a
`wgs84` projection. To get the original data from `wkt` format, we will
use the `st_geomfromwkt` functions. We can execute this spatial query
using `DBI`:

``` r
DBI::dbGetQuery(sc, "
  SELECT area, state, count(*) cnt FROM
    (SELECT area, ST_GeomFromWKT(polygons.geom ,'4326') as y FROM polygons) polygons
  INNER JOIN
    (SELECT ST_GeomFromWKT (points.geom,'4326') as x, state, city FROM points) points
  WHERE ST_Contains(polygons.y,points.x) GROUP BY area, state")
```

``` 
             area state cnt
1      texas area    TX  10
2     dakota area    SD   1
3     dakota area    ND  10
4 california area    CA  10
5   new york area    NY   9
```

You can also perform this query using `dplyr 0.9` installed through:

``` r
remotes::install_github("tidyverse/dplyr")
remotes::install_github("tidyverse/dbplyr")
```

Then, you can join as follows:

``` r
library(dplyr)
polygons_wkt <- mutate(polygons_wkt, y = st_geomfromwkt(geom, "4326"))
points_wkt <- mutate(points_wkt, x = st_geomfromwkt(geom, "4326"))

sc_res = inner_join(polygons_wkt, points_wkt, by = sql("st_contains(y, x)")) %>%
  group_by(area, state) %>%
  summarise(cnt = n())
  
sc_res %>%
  head()
```

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
```

The final result can be present by `leaflet`.

```
Idx_df = collect(sc_res) %>% 
right_join(polygons,by = (c("area"="area"))) %>% 
sf::st_as_sf(wkt="geom")

Idx_df %>% 
leaflet::leaflet() %>% 
leaflet::addTiles() %>% 
leaflet::addPolygons(popup = ~as.character(cnt),color=~colormap::colormap_pal()(cnt)) 

```

![](https://image-static.segmentfault.com/305/306/3053068814-5c9803c8d59a7)

Finally, we can disconnect:

``` r
spark_disconnect_all()
```

## Performance

### Configuration

To improve performance, it is recommended to use the `KryoSerializer`
and the `GeoSparkKryoRegistrator` before connecting as follows:

``` r
conf <- spark_config()
conf$spark.serializer <- "org.apache.spark.serializer.KryoSerializer"
conf$spark.kryo.registrator <- "org.datasyslab.geospark.serde.GeoSparkKryoRegistrator"
```

### Benchmarks

This performance comparison is an extract from the original [GeoSpark: A
Cluster Computing Framework for Processing Spatial
Data](https://pdfs.semanticscholar.org/347d/992ceec645a28f4e7e45e9ab902cd75ecd92.pdf)
paper:

| No. | test case                                                                                                                                                            | the number of records |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| 1   | SELECT IDCODE FROM zhenlongxiang WHERE ST\_Disjoint(geom,ST\_GeomFromText(‘POLYGON((517000 1520000,619000 1520000,619000 2530000,517000 2530000,517000 1520000))’)); | 85,236 rows           |
| 2   | SELECT fid FROM cyclonepoint WHERE ST\_Disjoint(geom,ST\_GeomFromText(‘POLYGON((90 3,170 3,170 55,90 55,90 3))’,4326))                                               | 60,591 rows           |

Query
performance(ms),

| No. | PostGIS/PostgreSQL | GeoSpark SQL | ESRI Spatial Framework for Hadoop |
| --- | ------------------ | ------------ | --------------------------------- |
| 1   | 9631               | 480          | 40,784                            |
| 2   | 110872             | 394          | 64,217                            |

According to this papaer, the Geospark SQL definitely outperforms PG and
ESRI UDF under a very large data set.


If you are wondering how the spatial index accelerate the query process,
here is a good Uber example: [Unwinding Uber’s Most Efficient
Service](https://medium.com/@buckhx/unwinding-uber-s-most-efficient-service-406413c5871d#.dg5v6irao)
and the [Chinese translation
version](https://segmentfault.com/a/1190000008657566)

## Architecture

# ![](https://user-images.githubusercontent.com/5362577/53225664-bf6abc80-36b3-11e9-8b8e-41611fc7098e.png)

