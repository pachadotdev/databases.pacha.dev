# SQL Server 2017 + odbc
# > tictoc::tic()
# > copy_to(con, sj_all_revenue_large_f, temporary = F)
# > tictoc::toc()
# 57.695 sec elapsed

# MySQL 5.7 + RMySQL
# > tictoc::tic()
# > copy_to(con, sj_all_revenue_large_f, temporary = F)
# > tictoc::toc()
# 40.755 sec elapsed

# MySQL 5.7 + RMariaDB
# cancelled after 5 minutes

# MySQL 5.7 + odbc
# cancelled after 5 minutes

cd ~/Downloads
tar xvf mysql-connector-odbc-8.0.27-linux-glibc2.12-x86-64bit.tar.gz
cd mysql-connector-odbc-8.0.27-linux-glibc2.12-x86-64bit 
sudo cp -r bin/* /usr/local/bin/
sudo cp -r lib/* /usr/local/lib/

sudo myodbc-installer -a -d -n "MySQL ODBC 8.0 Driver" -t "Driver=/usr/local/lib/libmyodbc8w.so"
sudo myodbc-installer -a -d -n "MySQL ODBC 8.0" -t "Driver=/usr/local/lib/libmyodbc8a.so"

cat /etc/odbcinst.ini
