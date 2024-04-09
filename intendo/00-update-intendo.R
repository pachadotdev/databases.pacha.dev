# All the need to partition tables and connect/disconnect a lot is because of
# SQL Server backend
# see
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

# clone git@github.com:rich-iannone/intendo.git
# in the top directory before running this

# CHANGE THIS ACCORDINGLY: small, medium, large, xlarge, small_f, medium_f, large_f, xlarge_f
select_engine <- "postgres"
size <- paste0(c("large", "medium", "small"), "_f")

if (select_engine == "postgres") library(RPostgres)
if (select_engine == "mysql") library(RMySQL) # library(RMariaDB) for some reason copies really slow
# if (select_engine == "sqlserver") library(odbc)
library(dplyr)
library(tidyr)
library(glue)

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
      TrustServerCertificate = "yes"
    )
  }

  return(con)
}

for (s in size) {
  datasets <- c(
    glue("../intendo/data-{ gsub('_f', '', s) }/sj_all_revenue_{ s }.rds"),
    glue("../intendo/data-{ gsub('_f', '', s) }/sj_all_sessions_{ s }.rds"),
    glue("../intendo/data-{ gsub('_f', '', s) }/sj_user_summary_{ s }.rds"),
    glue("../intendo/data-{ gsub('_f', '', s) }/sj_users_daily_{ s }.rds")
  )

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

  con <- fun_con(select_engine)

  revenue <- readRDS(datasets[1])

  if (s == "large") {
    items <- revenue %>%
      distinct(item_name) %>%
      arrange(item_name) %>%
      mutate(item_id = row_number())

    items_type <- revenue %>%
      distinct(item_type) %>%
      arrange(item_type) %>%
      mutate(item_type_id = row_number())

    acquisitions <- revenue %>%
      distinct(acquisition) %>%
      arrange(acquisition) %>%
      mutate(acquisition_id = row_number())

    countries <- revenue %>%
      distinct(country) %>%
      arrange(country) %>%
      mutate(country_id = row_number())
  }

  sessions <- readRDS(datasets[2])

  summary <- readRDS(datasets[3])

  if (s == "large") {
    acquisitions2 <- summary %>%
      distinct(acquisition) %>%
      arrange(acquisition) %>%
      mutate(acquisition_id = row_number())

    acquisitions3 <- anti_join(acquisitions, acquisitions2)

    if (nrow(acquisitions3) > 0) {
      acquisitions <- acquisitions %>%
        bind_rows(acquisitions3) %>%
        select(-acquisition_id) %>%
        distinct(acquisition) %>%
        arrange(acquisition) %>%
        mutate(acquisition_id = row_number())
    }

    countries2 <- summary %>%
      distinct(country) %>%
      arrange(country) %>%
      mutate(country_id = row_number())

    countries3 <- anti_join(countries, countries2)

    if (nrow(countries3) > 0) {
      countries <- countries %>%
        bind_rows(countries3) %>%
        select(-country_id) %>%
        distinct(country) %>%
        arrange(country) %>%
        mutate(country_id = row_number())
    }

    devices <- summary %>%
      distinct(device_name) %>%
      arrange(device_name) %>%
      mutate(device_id = row_number())
  }

  daily <- readRDS(datasets[4])

  if (s == "large") {
    countries4 <- daily %>%
      distinct(country) %>%
      arrange(country) %>%
      mutate(country_id = row_number())

    countries5 <- anti_join(countries, countries4)

    if (nrow(countries5) > 0) {
      countries <- countries %>%
        bind_rows(countries5) %>%
        select(-country_id) %>%
        distinct(country) %>%
        arrange(country) %>%
        mutate(country_id = row_number())
    }

    acquisitions4 <- daily %>%
      distinct(acquisition) %>%
      arrange(acquisition) %>%
      mutate(acquisition_id = row_number())

    acquisitions5 <- anti_join(acquisitions, acquisitions4)

    if (nrow(acquisitions5) > 0) {
      acquisitions <- acquisitions %>%
        bind_rows(acquisitions5) %>%
        select(-acquisition_id) %>%
        distinct(acquisition) %>%
        arrange(acquisition) %>%
        mutate(acquisition_id = row_number())
    }
  }

  revenue <- revenue %>%
    left_join(items, by = "item_name") %>%
    left_join(items_type, by = "item_type") %>%
    left_join(acquisitions, by = "acquisition") %>%
    left_join(countries, by = "country") %>%
    select(
      player_id:time, item_type_id, item_id, item_revenue,
      session_duration, start_day, acquisition_id, country_id
    )

  summary <- summary %>%
    left_join(acquisitions, by = "acquisition") %>%
    left_join(countries, by = "country") %>%
    left_join(devices, by = "device_name") %>%
    select(player_id:start_day, country_id, acquisition_id, device_id)

  daily <- daily %>%
    left_join(acquisitions, by = "acquisition") %>%
    left_join(countries, by = "country") %>%
    select(player_id:rev_all_total, country_id, acquisition_id)

  if (s == "large") {
    dbWriteTable(con, glue("items"), items, row.names = F)
    dbWriteTable(con, glue("items_type"), items_type, row.names = F)
    dbWriteTable(con, glue("acquisitions"), acquisitions, row.names = F)
    dbWriteTable(con, glue("countries"), countries, row.names = F)
    dbWriteTable(con, glue("devices"), devices, row.names = F)
  }

  dbWriteTable(con, glue("revenue_{ s }"), revenue, row.names = F)
  dbWriteTable(con, glue("sessions_{ s }"), sessions, row.names = F)
  dbWriteTable(con, glue("summary_{ s }"), summary, row.names = F)
  dbWriteTable(con, glue("daily_{ s }"), daily, row.names = F)

  # constraints
  if (s == "large") {
    dbSendQuery(con, glue("ALTER TABLE items ADD CONSTRAINT items_{ s }_pk PRIMARY KEY (item_id)"))
    dbSendQuery(con, glue("ALTER TABLE items_type ADD CONSTRAINT items_type_{ s }_pk PRIMARY KEY (item_type_id)"))
    dbSendQuery(con, glue("ALTER TABLE acquisitions ADD CONSTRAINT acquisitions_{ s }_pk PRIMARY KEY (acquisition_id)"))
    dbSendQuery(con, glue("ALTER TABLE countries ADD CONSTRAINT countries_{ s }_pk PRIMARY KEY (country_id)"))
    dbSendQuery(con, glue("ALTER TABLE devices ADD CONSTRAINT devices_{ s }_pk PRIMARY KEY (device_id)"))
  }

  # foreign keys
  dbSendQuery(con, glue("ALTER TABLE revenue_{ s } ADD CONSTRAINT revenue_items_{ s }_fk FOREIGN KEY (item_id) REFERENCES items(item_id)"))
  dbSendQuery(con, glue("ALTER TABLE revenue_{ s } ADD CONSTRAINT revenue_items_type_{ s }_fk FOREIGN KEY (item_type_id) REFERENCES items_type(item_type_id)"))
  dbSendQuery(con, glue("ALTER TABLE revenue_{ s } ADD CONSTRAINT revenue_acquisitions_{ s }_fk FOREIGN KEY (acquisition_id) REFERENCES acquisitions(acquisition_id)"))
  dbSendQuery(con, glue("ALTER TABLE revenue_{ s } ADD CONSTRAINT revenue_countries_{ s }_fk FOREIGN KEY (country_id) REFERENCES countries(country_id)"))

  dbSendQuery(con, glue("ALTER TABLE summary_{ s } ADD CONSTRAINT summary_acquisitions_{ s }_fk FOREIGN KEY (acquisition_id) REFERENCES acquisitions(acquisition_id)"))
  dbSendQuery(con, glue("ALTER TABLE summary_{ s } ADD CONSTRAINT summary_countries_{ s }_fk FOREIGN KEY (country_id) REFERENCES countries(country_id)"))
  dbSendQuery(con, glue("ALTER TABLE summary_{ s } ADD CONSTRAINT summary_devices_{ s }_fk FOREIGN KEY (device_id) REFERENCES devices(device_id)"))

  dbSendQuery(con, glue("ALTER TABLE daily_{ s } ADD CONSTRAINT daily_acquisitions_{ s }_fk FOREIGN KEY (acquisition_id) REFERENCES acquisitions(acquisition_id)"))
  dbSendQuery(con, glue("ALTER TABLE daily_{ s } ADD CONSTRAINT daily_countries_{ s }_fk FOREIGN KEY (country_id) REFERENCES countries(country_id)"))

  dbDisconnect(con)
}
