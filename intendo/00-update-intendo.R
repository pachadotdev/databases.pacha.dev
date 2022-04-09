# All the need to partition tables and connect/disconnect a lot is because of SQL Server backend
library(RPostgres)
# library(RMariaDB) # for some reason copies really slow
library(RMySQL)
library(odbc)
library(dplyr)
library(tidyr)
library(glue)
# see https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

sj_all_revenue_large_f <- readRDS("../intendo/data-large/sj_all_revenue_large_f.rds")
sj_all_revenue_large <- readRDS("../intendo/data-large/sj_all_revenue_large.rds")
sj_all_sessions_large_f <- readRDS("../intendo/data-large/sj_all_sessions_large_f.rds")
sj_all_sessions_large <- readRDS("../intendo/data-large/sj_all_sessions_large.rds")
sj_user_summary_large_f <- readRDS("../intendo/data-large/sj_user_summary_large_f.rds")
sj_user_summary_large <- readRDS("../intendo/data-large/sj_user_summary_large.rds")
sj_users_daily_large_f <- readRDS("../intendo/data-large/sj_users_daily_large_f.rds")
sj_users_daily_large <- readRDS("../intendo/data-large/sj_users_daily_large.rds")

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

con <- fun_con("sqlserver")
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
sj_all_revenue_large_f <- sj_all_revenue_large_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_revenue_large_f$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_all_revenue_large_f",
    sj_all_revenue_large_f %>% 
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
sj_all_revenue_large <- sj_all_revenue_large %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_revenue_large$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_all_revenue_large",
    sj_all_revenue_large %>% 
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
sj_all_sessions_large_f <- sj_all_sessions_large_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_sessions_large_f$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_all_sessions_large_f",
    sj_all_sessions_large_f %>% 
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
sj_all_sessions_large <- sj_all_sessions_large %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_all_sessions_large$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_all_sessions_large",
    sj_all_sessions_large %>% 
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
sj_user_summary_large_f <- sj_user_summary_large_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_user_summary_large_f$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_user_summary_large_f",
    sj_user_summary_large_f %>% 
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
sj_user_summary_large <- sj_user_summary_large %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_user_summary_large$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_user_summary_large",
    sj_user_summary_large %>% 
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
sj_users_daily_large_f <- sj_users_daily_large_f %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_users_daily_large_f$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_users_daily_large_f",
    sj_users_daily_large_f %>% 
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
sj_users_daily_large <- sj_users_daily_large %>% 
  mutate(n = row_number() %/% 50000) %>% 
  group_by(n) %>% 
  nest()

for (i in sj_users_daily_large$n) {
  cat(paste0(i, " "))
  con <- fun_con("sqlserver")
  dbWriteTable(
    con, 
    "sj_users_daily_large",
    sj_users_daily_large %>% 
      ungroup() %>% 
      filter(n == i) %>% 
      select(data) %>% 
      unnest(cols = c(data)),
    temporary = F, overwrite = F, append = T
  )
  dbDisconnect(con)
}
tictoc::toc()
