#' @examples
#' \dontrun{
#' register_gis(sc)
#' }
#' @export
register_gis <- function(sc) {
        sql_context <- invoke_new(sc, "org.apache.spark.sql.SQLContext", spark_context(sc))
        invoke_new(sql_context,"org.datasyslab.geosparksql.utils.GeoSparkSQLRegistrator","registerAll")
}
