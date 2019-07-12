context("st_join st_contains")

sc <- testthat_spark_connection()
test_requires("dplyr")
test_requires("knitr")

test_that("st_join() works", {
    expect_known_output({
        inner_join(st_example(sc, "polygons") %>% dplyr::select(area, geom_x = geom) ,
                   st_example(sc, "points") %>% dplyr::select(city, state, geom_y = geom) ,
                   sql_on = sql("st_contains(`geom_x`,`geom_y`)")) %>%
            collect() %>%
            knitr::kable()
    }
       ,
        "output/st_join.txt",
        print = TRUE
    )
})