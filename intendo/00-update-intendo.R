# All the need to partition tables and connect/disconnect a lot is because of SQL Server backend
# see https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

select_engine <- "sqlserver"

library(RPostgres)
# library(RMariaDB) # for some reason copies really slow
library(RMySQL)
library(odbc)
library(dplyr)
library(tidyr)
library(glue)

sj_all_revenue_small_f <- readRDS("../intendo/data-small/sj_all_revenue_small_f.rds")
sj_all_revenue_small <- readRDS("../intendo/data-small/sj_all_revenue_small.rds")
sj_all_sessions_small_f <- readRDS("../intendo/data-small/sj_all_sessions_small_f.rds")
sj_all_sessions_small <- readRDS("../intendo/data-small/sj_all_sessions_small.rds")
sj_user_summary_small_f <- readRDS("../intendo/data-small/sj_user_summary_small_f.rds")
sj_user_summary_small <- readRDS("../intendo/data-small/sj_user_summary_small.rds")
sj_users_daily_small_f <- readRDS("../intendo/data-small/sj_users_daily_small_f.rds")
sj_users_daily_small <- readRDS("../intendo/data-small/sj_users_daily_small.rds")

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

con <- fun_con(select_engine)
if(any(class(con) %in% c("MySQLConnection", "Microsoft SQL Server"))) {
  # MYSQL/SQL SERVER ONLY
  dbSendQuery(con, "USE intendo")  
}

tbls <- dbListTables(con)
tbls <- grep("^daily_users$|^revenue$|^users$|^sj_", tbls, value = T)

for (t in tbls) {
  dbGetQuery(con, glue("DROP TABLE {t}"))
}

dbDisconnect(con)

tictoc::tic()
sj_all_revenue_small_f <- sj_all_revenue_small_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_revenue_small_f$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_all_revenue_small_f",
    sj_all_revenue_small_f %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_all_revenue_small <- sj_all_revenue_small %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_revenue_small$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_all_revenue_small",
    sj_all_revenue_small %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_all_sessions_small_f <- sj_all_sessions_small_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_sessions_small_f$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_all_sessions_small_f",
    sj_all_sessions_small_f %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_all_sessions_small <- sj_all_sessions_small %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_sessions_small$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_all_sessions_small",
    sj_all_sessions_small %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_user_summary_small_f <- sj_user_summary_small_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_user_summary_small_f$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_user_summary_small_f",
    sj_user_summary_small_f %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_user_summary_small <- sj_user_summary_small %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_user_summary_small$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_user_summary_small",
    sj_user_summary_small %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_users_daily_small_f <- sj_users_daily_small_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_users_daily_small_f$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_users_daily_small_f",
    sj_users_daily_small_f %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()

tictoc::tic()
sj_users_daily_small <- sj_users_daily_small %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_users_daily_small$n) {
  cat(paste0(i, " "))
  con <- fun_con(select_engine)
  dbWriteTable(
    con, 
    "sj_users_daily_small",
    sj_users_daily_small %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()
