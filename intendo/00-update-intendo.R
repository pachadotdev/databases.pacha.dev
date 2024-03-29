# All the need to partition tables and connect/disconnect a lot is because of 
# SQL Server backend
# see 
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

# clone
# git@github.com:rich-iannone/intendo.git
# before running this

# CHANGE THIS ACCORDINGLY: small, medium, large, xlarge
select_engine <- "postgres"
size <- "xlarge"

if (select_engine == "postgres") library(RPostgres)
if (select_engine == "mysql") library(RMySQL) # library(RMariaDB) for some reason copies really slow
# if (select_engine == "sqlserver") library(odbc)
library(dplyr)
library(tidyr)
library(glue)

datasets <- c(
  glue("../intendo/data-{size}/sj_all_revenue_{size}_f.rds"),
  glue("../intendo/data-{size}/sj_all_revenue_{size}.rds"),
  glue("../intendo/data-{size}/sj_all_sessions_{size}_f.rds"),
  glue("../intendo/data-{size}/sj_all_sessions_{size}.rds"),
  glue("../intendo/data-{size}/sj_user_summary_{size}_f.rds"),
  glue("../intendo/data-{size}/sj_user_summary_{size}.rds"),
  glue("../intendo/data-{size}/sj_users_daily_{size}_f.rds"),
  glue("../intendo/data-{size}/sj_users_daily_{size}.rds")
)

tbl_names <- gsub(".*/|\\.rds", "", datasets)

fun_con <- function(type) {
  if (type == "postgres") {
    con <- dbConnect(
      Postgres(),
      user = Sys.getenv("dbedu_usr"),
      password = Sys.getenv("dbedu_pwd"),
      dbname = "intendo",
      host = "databases.pacha.dev"
    )
  } 
  
  if (type == "mysql") {
    con <- dbConnect(
      MySQL(),
      user = Sys.getenv("dbedu_usr"),
      password = Sys.getenv("dbedu_pwd"),
      dbname = "intendo",
      host = "databases.pacha.dev"
    )
  }
  
  if (type == "sqlserver") {
    con <- dbConnect(
      odbc(),
      Driver = "ODBC Driver 18 for SQL Server",
      UID = Sys.getenv("dbedu_usr"),
      PWD = Sys.getenv("dbedu_pwd"),
      Database = "intendo",
      Server = "databases.pacha.dev",
      TrustServerCertificate="yes"
    )
  }
  
  return(con)
}

# con <- fun_con(select_engine)
# if(any(class(con) %in% c("MySQLConnection", "Microsoft SQL Server"))) {
#   # MYSQL/SQL SERVER ONLY
#   dbSendQuery(con, "USE intendo")  
# }
# tbls <- dbListTables(con)
# tbls <- grep("^daily_users$|^revenue$|^users$|^sj_", tbls, value = T)
# for (t in tbls) {
#   dbGetQuery(con, glue("DROP TABLE {t}"))
# }
# dbDisconnect(con)

for (j in seq_along(datasets)) {
  cat(paste0(datasets[j], "\n"))
  tictoc::tic()
  d <- readRDS(datasets[j]) %>% 
    mutate(n = row_number() %/% 50000) %>% 
    group_by(n) %>% 
    nest()
  for (i in d$n) {
    cat(paste0(i, " "))
    con <- fun_con(select_engine)
    dbWriteTable(
      con, 
      tbl_names[j],
      d %>% 
        ungroup() %>% 
        filter(n == i) %>% 
        select(data) %>% 
        unnest(cols = c(data)),
      temporary = F, overwrite = F, append = T
    )
    dbDisconnect(con)
  }
  rm(d)
  tictoc::toc()
}
