library(RPostgres)
library(dplyr)
library(arrow)
library(purrr)
library(lubridate)

# Intendo ----

## see https://www.databases.pacha.dev/#intendo-database

con <- dbConnect(
  Postgres(),
  user = Sys.getenv("DB_USR"),
  password = Sys.getenv("DB_PWD"),
  dbname = "intendo",
  host = "databases.pacha.dev"
)

dbListTables(con)

## daily users

tbl(con, "daily_users") %>% glimpse()

year_month <- tbl(con, "daily_users") %>% 
  select(time) %>% 
  mutate(
    year = substr(time, 1, 4),
    month = substr(time, 6, 7)
  ) %>% 
  select(-time) %>% 
  distinct() %>% 
  collect()

map2(
  year_month %>% select(year) %>% pull(),
  year_month %>% select(month) %>% pull(),
  function(y,m) {
    tbl(con, "daily_users") %>% 
      mutate(
        year = substr(time, 1, 4),
        month = substr(time, 6, 7)
      ) %>% 
      filter(
        year == y, month == m
      ) %>% 
      collect() %>% 
      group_by(year, month) %>% 
      write_dataset("intendo/daily_users", hive_style = F)
  }
)

## revenue

tbl(con, "revenue") %>% glimpse()

### we already know the periods (e.g. month-year)

map2(
  year_month %>% select(year) %>% pull(),
  year_month %>% select(month) %>% pull(),
  function(y,m) {
    tbl(con, "revenue") %>% 
      mutate(
        year = substr(time, 1, 4),
        month = substr(time, 6, 7)
      ) %>% 
      filter(
        year == y, month == m
      ) %>% 
      collect() %>% 
      group_by(year, month) %>% 
      write_dataset("intendo/revenue", hive_style = F)
  }
)

## users

tbl(con, "users") %>% glimpse()

map2(
  year_month %>% select(year) %>% pull(),
  year_month %>% select(month) %>% pull(),
  function(y,m) {
    tbl(con, "users") %>% 
      mutate(
        year = substr(first_login, 1, 4),
        month = substr(first_login, 6, 7)
      ) %>% 
      filter(
        year == y, month == m
      ) %>% 
      collect() %>% 
      group_by(year, month) %>% 
      write_dataset("intendo/users", hive_style = F)
  }
)

d <- open_dataset("intendo/users", partitioning = c("year", "month"))

d %>% 
  filter(year == 2015, month == 6) %>% 
  collect()
