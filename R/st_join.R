#' @title spatial join
#' @name st_join
#' @import dplyr
#' @param x a spark spatial data frame
#' @param y a spark spatial data frame
#' @param join join condition
#' @description 
#' st_join: spatial join 
#' 
#' @import utils
#' 
#' @details alternative values for argument join are: ST_Contains, ST_Intersects, ST_Within, ST_Equals, ST_Crosses, ST_Touches, ST_Overlaps, ST_Distance
#' 
#' @return a spark spatial data frame, joined based on geometry
#' 
#' @examples
#' \dontrun{
#' 
#' library(dplyr)
#' polygons <- read.table(system.file(package="geospark","examples/polygons.txt"),
#'                        sep="|", col.names=c("area","geom"))
#' points <- read.table(system.file(package="geospark","examples/points.txt"),
#'                        sep="|", col.names=c("city","state","geom"))
#' polygons_wkt <- copy_to(sc, polygons)
#' points_wkt <- copy_to(sc, points)

#' polygons_wkt <- mutate(polygons_wkt, y = st_geomfromwkt(geom))
#' points_wkt <- mutate(points_wkt, x = st_geomfromwkt(geom))

#' sc_res <- st_join(polygons_wkt, points_wkt, join = sql("st_contains(y,x)"))
#'     group_by(area, state) %>%
#'     summarise(cnt = n()) 
#' }
#' @export
st_join <- function(x, y, join = NULL) {
    full_join(x %>% mutate(dummy_s4pu629cnd=TRUE) %>% compute(),
              y %>% mutate(dummy_s4pu629cnd=TRUE) %>% compute(),
              by = "dummy_s4pu629cnd") %>% 
        filter(join) %>%
        select(-dummy_s4pu629cnd)
}
