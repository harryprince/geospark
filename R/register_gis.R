#' @title Enable GIS SQL
#' @name register_gis
#' @import sparklyr
#' @param sc a spark connection
#' 
#' Used by 'sparklyr' to initilize GIS SQL.
#' 
#' @examples
#' library(geospark)
#' library(sparklyr)
#' 
#' sc <- spark_connect(master = "spark://HOST:PORT")
#' 
#' # spark_connect() calls register_gis() automatically, as in:
#' register_gis(sc)
#' 
#' @return a GIS spark connection
#' 
#' @export
register_gis <- function(sc) {
    sparklyr::invoke_static(sc,"org.datasyslab.geosparksql.utils.GeoSparkSQLRegistrator","registerAll",spark_session(sc))
    return(invisible(sc))
}
