spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    packages = c(
      "org.datasyslab:geospark-sql_2.3:1.2.0",
      "com.vividsolutions:jts-core:1.14.0",
      "org.datasyslab:geospark:1.2.0"
    ),
    initializer = function(sc, ...) {
      register_gis(sc)
    }
  )
}

#' @import sparklyr dplyr
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
