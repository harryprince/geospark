
library(testthat)
library(geospark)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
    test_check("geospark")
    on.exit({spark_disconnect_all()})
}