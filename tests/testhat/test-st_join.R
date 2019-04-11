context("st_join st_contains")

sc <- testthat_spark_connection()
test_requires("dplyr")
test_requires("knitr")

test_that("st_join() works", {
    expect_known_output({
        
        st_join(st_plg_example(sc) ,
                st_pit_example(sc) , join = sql("st_contains(`geom.x`,`geom.y`)")) %>%
            collect() %>%
            knitr::kable()
    }
       ,
        "output/st_join.txt",
        print = TRUE
    )
})