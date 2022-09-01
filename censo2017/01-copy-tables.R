library(RPostgres)
library(dplyr)
library(tidyr)
library(censo2017)

con <- censo_conectar()

tbl_names <- dbListTables(con)

fun_con <- function(type) {
  con <- dbConnect(
    Postgres(),
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
  d <- tbl(con, tbl_names[j]) %>% 
    collect() %>% 
    mutate(n = row_number() %/% 500000) %>% 
    group_by(n) %>% 
    nest()
  for (i in d$n) {
    cat(paste0(i, " "))
    con2 <- fun_con(select_engine)
    dbWriteTable(
      con2, 
      tbl_names[j],
      d %>% 
        ungroup() %>% 
        filter(n == i) %>% 
        select(data) %>% 
        unnest(cols = c(data)),
      temporary = F, overwrite = F, append = T
    )
    dbDisconnect(con2)
  }
  rm(d)
  tictoc::toc()
}

dbDisconnect(con, shutdown = T)
