spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    packages = c(
      paste0("org.apache.sedona:sedona-sql-3.0_2.12:1.0.0-incubating"),
      "org.locationtech.jts:jts-core:1.18.0",
      "org.apache.sedona:sedona-core-3.0_2.12:1.0.0-incubating"
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
