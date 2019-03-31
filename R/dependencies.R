spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    jars = c(
      system.file(
        sprintf("java/geospark-sql_%s-%s.jar",
                sparklyr::spark_dependency_fallback(spark_version, c("2.1", "2.2", "2.3")),
                "1.2.0"),
        package = "geospark"
      ),
      system.file(
        "java/geospark-1.2.0.jar",
        package = "geospark"
      ),
      system.file(
        "java/geospark-viz-1.2.0.jar",
        package = "geospark"
      )
    ),
    packages = c(
      sprintf("org.datasyslab:geospark-sql_2.3:1.2.0"),
      "com.vividsolutions:jts-core:1.14.0",
      "org.datasyslab:geospark:1.2.0"
    ),
    initializer = function(sc, ...) {
      register_gis(sc)
    },
    catalog = "https://github.com/javierluraschi/geospark/blob/master/inst/java/%s?raw=true"
  )
}

#' @import sparklyr
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
