#' Spark polygons example.
#'
#' @examples
#' \dontrun{
#' library(sparklyr)
#' sc <- spark_connect(master = "local")
#' register_gis(sc)
#' st_plg_example(sc)
#' }
#' @export
st_plg_example <- function(sc) {
    polygons <- read.table(system.file(package="geospark","examples/polygons.txt"), sep="|", col.names=c("area","geom"))
    polygons_wkt <- copy_to(dest = sc, df = polygons, name = "geospark_example_polygons", overwrite = T) %>% 
        mutate(geom = st_geomfromwkt(geom))
    return(polygons_wkt)
}

#' Spark points example.
#'
#' @examples
#' \dontrun{
#' library(sparklyr)
#' sc <- spark_connect(master = "local")
#' register_gis(sc)
#' st_pit_example(sc)
#' }
#' @export
st_pit_example <- function(sc) {
    points <- read.table(system.file(package="geospark","examples/points.txt"), sep="|", col.names=c("city","state","geom"))
    points_wkt <- copy_to(dest = sc, df = points, name = "geospark_example_points", overwrite = T) %>% 
        mutate(geom = st_geomfromwkt(geom))
    return(points_wkt)
}