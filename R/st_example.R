#' Spark geometry example.
#'
#' @param sc an object of spark connection
#' @param geom a string of geometry type 
#'
#' @examples
#' library(geospark)
#' library(sparklyr)
#' library(utils)
#' 
#' # use the proper master, like 'local', 'yarn', etc.
#' sc <- spark_connect(master = "spark://HOST:PORT")
#' 
#' st_example(sc, "polygons")
#' st_example(sc, "points")
#' 
#' @details geometry can be "polygons" or "points"
#' 
#' @return a data.frame contains wkt format column example
#' 
#' @export
st_example <- function(sc, geom = "polygons") {
    geoms <- utils::read.table(system.file(package="geospark",sprintf("examples/%s.txt",geom)), sep="|")
    switch (geom,
        "polygons" = {
            colnames(geoms) <- c("area","geom")
        },
        "points" = {
            colnames(geoms) <- c("city","state","geom")
        }
    )
    
    geoms_wkt <- copy_to(dest = sc, df = geoms, name = sprintf("geospark_example_%s",geom), overwrite = T) %>% 
        dplyr::mutate(geom = dplyr::sql("st_geomfromwkt(geom)"))
    
    return(geoms_wkt)
}

