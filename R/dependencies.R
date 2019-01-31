spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    jars = c(
      system.file(
        sprintf("java/geospark-sql_%s-%s.jar", spark_version, "1.1.3"),
        package = "geospark"
      ),
      system.file(
          "java/geospark-1.1.3.jar",
          package = "geospark"
      ),
      system.file(
          "java/geospark-viz-1.1.3.jar",
          package = "geospark"
      )
    ),
    packages = c(
        sprintf("org.datasyslab:geospark-sql_%s:1.1.3",spark_version),
        "com.vividsolutions:jts-core:1.14.0",
        "org.datasyslab:geospark:1.1.3"
    )
  )
}

#' @import sparklyr
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
