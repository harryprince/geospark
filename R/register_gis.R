#' @import sparklyr
#' @description 
#' register_gis: to enable spark geospark sql in sc
#' @examples
#' \dontrun{
#' register_gis(sc)
#' }
#' @export
register_gis <- function(sc) {
    sparklyr::invoke_static(sc,"org.datasyslab.geosparksql.utils.GeoSparkSQLRegistrator","registerAll",spark_session(sc))
    return(invisible(sc))
}
