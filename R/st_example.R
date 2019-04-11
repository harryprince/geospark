#' Spark geometry example.
#'
#' @examples
#' \dontrun{
#' library(sparklyr)
#' sc <- spark_connect(master = "local")
#' register_gis(sc)
#' polygons_wkt <- st_example(sc, "polygons")
#' point_wkt <- st_example(sc, "points")
#' }
#' @details geometry can be  "polygons" or "points"
#' 
#' @export
st_example <- function(sc, geom = "polygons") {
    geoms <- read.table(system.file(package="geospark",sprintf("examples/%s.txt",geom)), sep="|")
    switch (geom,
        "polygons" = {
            colnames(geoms) <- c("area","geom")
        },
        "points" = {
            colnames(geoms) <- c("city","state","geom")
        }
    )
    
    geoms_wkt <- copy_to(dest = sc, df = geoms, name = sprintf("geospark_example_%s",geom), overwrite = T) %>% 
        mutate(geom = st_geomfromwkt(geom))
    return(geoms_wkt)
}

