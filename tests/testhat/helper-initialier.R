"%||%" <- function(x, y) {
    if (is.null(x)) y else x
}

# helper functions from sparklyr tests
# https://github.com/rstudio/sparklyr/blob/master/tests/testthat/helper-initialize.R
testthat_spark_connection <- function() {
    version <- Sys.getenv("SPARK_VERSION", unset = "2.3.0")
    
    spark_installed <- sparklyr::spark_installed_versions()
    if (nrow(spark_installed[spark_installed$spark == version, ]) == 0) {
        options(sparkinstall.verbose = TRUE)
        sparklyr::spark_install(version)
    }
    
    expect_gt(nrow(sparklyr::spark_installed_versions()), 0)
    
    # generate connection if none yet exists
    connected <- FALSE
    if (exists(".testthat_spark_connection", envir = .GlobalEnv)) {
        sc <- get(".testthat_spark_connection", envir = .GlobalEnv)
        connected <- sparklyr::connection_is_open(sc)
    }
    
    if (!connected) {
        config <- sparklyr::spark_config()
        
        options(sparklyr.sanitize.column.names.verbose = TRUE)
        options(sparklyr.verbose = TRUE)
        options(sparklyr.na.omit.verbose = TRUE)
        options(sparklyr.na.action.verbose = TRUE)
        
        sc <- sparklyr::spark_connect(master = "local", version = version, config = config)
        assign(".testthat_spark_connection", sc, envir = .GlobalEnv)
    }
    
    # retrieve spark connection
    get(".testthat_spark_connection", envir = .GlobalEnv)
}

testthat_tbl <- function(name) {
    sc <- testthat_spark_connection()
    tbl <- tryCatch(dplyr::tbl(sc, name), error = identity)
    if (inherits(tbl, "error")) {
        data <- eval(as.name(name), envir = parent.frame())
        tbl <- dplyr::copy_to(sc, data, name = name)
    }
    tbl
}

skip_unless_verbose <- function(message = NULL) {
    message <- message %||% "Verbose test skipped"
    verbose <- Sys.getenv("SPARKLYR_TESTS_VERBOSE", unset = NA)
    if (is.na(verbose)) skip(message)
    invisible(TRUE)
}

test_requires <- function(...) {
    
    for (pkg in list(...)) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            fmt <- "test requires '%s' but '%s' is not installed"
            skip(sprintf(fmt, pkg, pkg))
        }
    }
    
    invisible(TRUE)
}