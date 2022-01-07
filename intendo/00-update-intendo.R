library(RPostgres)
# library(RMariaDB) # for some reason copies really slow
library(RMySQL)
library(odbc)
library(dplyr)
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

# con <- dbConnect(
#   Postgres(),
#   user = Sys.getenv("dbedu_usr"),
#   password = Sys.getenv("dbedu_pwd"),
#   dbname = "intendo",
#   host = "databases.pacha.dev"
# )

con <- dbConnect(
  MySQL(),
  user = Sys.getenv("dbedu_usr"),
  password = Sys.getenv("dbedu_pwd"),
  dbname = "intendo",
  host = "databases.pacha.dev"
)

# con <- dbConnect(
#   odbc(),
#   Driver = "MySQL ODBC 8.0 Driver",
#   UID = Sys.getenv("dbedu_usr"),
#   PWD = Sys.getenv("dbedu_pwd"),
#   Database = "intendo",
#   Server = "databases.pacha.dev"
# )

# con <- dbConnect(
#   odbc(),
#   Driver = "ODBC Driver 17 for SQL Server",
#   UID = Sys.getenv("dbedu_usr"),
#   PWD = Sys.getenv("dbedu_pwd"),
#   Database = "intendo",
#   Server = "databases.pacha.dev"
# )

# MYSQL/SQL SERVER ONLY
# dbSendQuery(con, "USE intendo")

tbls <- dbListTables(con)
tbls <- grep("^daily_users$|^revenue$|^users$|^sj_", tbls, value = T)

for (t in tbls) {
  dbGetQuery(con, glue("DROP TABLE {t}"))
}

tictoc::tic()
# copy_to(con, sj_all_revenue_large_f, temporary = F)
dbWriteTable(con, "sj_all_revenue_large_f", sj_all_revenue_large_f,
             temporary = F)
tictoc::toc()

# copy_to(con, sj_all_revenue_large, temporary = F)
# copy_to(con, sj_all_sessions_large_f, temporary = F)
# copy_to(con, sj_all_sessions_large, temporary = F)
# copy_to(con, sj_user_summary_large_f, temporary = F)
# copy_to(con, sj_user_summary_large, temporary = F)
# copy_to(con, sj_users_daily_large_f, temporary = F)
# copy_to(con, sj_users_daily_large, temporary = F)

dbWriteTable(con, "sj_all_revenue_large", sj_all_revenue_large, temporary = F)
dbWriteTable(con, "sj_all_sessions_large_f", sj_all_sessions_large_f, temporary = F)
dbWriteTable(con, "sj_all_sessions_large", sj_all_sessions_large, temporary = F)
dbWriteTable(con, "sj_user_summary_large_f", sj_user_summary_large, temporary = F)
dbWriteTable(con, "sj_user_summary_large", sj_user_summary_large, temporary = F)
dbWriteTable(con, "sj_users_daily_large_f", sj_users_daily_large_f, temporary = F)
dbWriteTable(con, "sj_users_daily_large", sj_users_daily_large, temporary = F)

dbDisconnect(con)
