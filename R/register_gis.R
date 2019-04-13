#' @title Enable GIS SQL
#' @name register_gis
#' @import sparklyr
#' @param sc a spark connection
#' @description 
#' register_gis: to enable spark geospark sql in sc, the more GIS SQL references could be found at https://github.com/harryprince/geospark/blob/master/Reference.md
#' @examples
#' \dontrun{
#' register_gis(sc)
#' point = DBI::dbGetQuery(sc,"SELECT ST_GeomFromWKT('POINT(40.7128,-74.0060)') AS geometry")
#' }
#' 
#' @return a GIS spark connection
#' 
#' @export
register_gis <- function(sc) {
    sparklyr::invoke_static(sc,"org.datasyslab.geosparksql.utils.GeoSparkSQLRegistrator","registerAll",spark_session(sc))
    return(invisible(sc))
}
