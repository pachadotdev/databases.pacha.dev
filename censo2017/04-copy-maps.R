library(RPostgres)
# library(RPostgreSQL) 
library(dplyr)
library(tidyr)
library(sf)

tbl_names <- c("mapa_regiones", "mapa_provincias", "mapa_comunas", 
               "mapa_zonas", "mapa_calles")

shp_names <- c("regiones_15r.shp", "provincias_15r.shp", "comunas_15r.shp", 
               "zonas_15r.shp", "calles_15r.shp")

fun_con <- function() {
  con <- dbConnect(
    Postgres(),
    # PostgreSQL(),
    user = Sys.getenv("dbedu_usr"),
    password = Sys.getenv("dbedu_pwd"),
    dbname = "censo2017",
    host = "databases.pacha.dev"
  )
  
  return(con)
}

for (j in seq_along(tbl_names)) {
  cat(paste0(tbl_names[j], "\n"))
  tictoc::tic()
  d <- read_sf(paste0("~/github/censo2017-cartografias/", shp_names[j])) %>% 
    ungroup()
  con <- fun_con()
  # dbWriteTable(
  #   con, 
  #   tbl_names[j],
  #   d %>% 
  #     ungroup(),
  #   temporary = F, overwrite = F, append = T
  # )
  st_write(d, con, tbl_names[j])
  dbDisconnect(con)
  rm(d)
  tictoc::toc()
}
