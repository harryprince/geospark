spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    packages = c(
      paste0("org.apache.sedona:sedona-python-adapter-",spark_version,"_",scala_version,":1.0.0-incubating"),
      "org.datasyslab:geotools-wrapper:geotools-24.0"
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
