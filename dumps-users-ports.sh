# Create SQL dump

sudo -i -u postgres
# if text dump then
# psql -U <username> -d <database-name> -h <host-name> -f <backup.sql>
pg_dump -Fc intendo > intendo-postgres.sql
md5sum intendo.sql > intendo.sql.md5

# Using the dumps locally

## Restore dumps

### PostgreSQL

sudo -i -u postgres
pg_restore intendo.sql -d intendo

### MySQL/MariaDB

mysqldump intendo > intendo-mysql.sql
mysql

CREATE DATABASE intendo;
exit;

sudo su
gunzip intendo-mysql.sql
mysql intendo < intendo-mysql.sql

### SQL Server

sqlcmd -S localhost -U SA

BACKUP DATABASE intendo TO DISK = 'filepath'; 
GO;

RESTORE DATABASE intendo FROM DISK = 'intendo-sqlserver.sql';
GO;

EXIT;

gunzip intendo-mysql.sql

## Create users

# You can create a generic user (let's say `student`) and grant read-only access.

### PostgreSQL

sudo -i -u postgres 
psql -d intendo

CREATE ROLE student;
CREATE ROLE teacher;
ALTER ROLE student WITH ENCRYPTED PASSWORD 'SomePassword';
ALTER ROLE teacher WITH ENCRYPTED PASSWORD 'SomePassword';
ALTER ROLE student WITH LOGIN;
ALTER ROLE teacher WITH LOGIN;

GRANT CONNECT ON DATABASE intendo TO student;
GRANT USAGE ON SCHEMA public TO student;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO student;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO student;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO student;
REVOKE CREATE ON SCHEMA public FROM public;

GRANT CONNECT ON DATABASE intendo TO teacher;
GRANT USAGE ON SCHEMA public TO teacher;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO teacher;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO teacher;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO teacher;
GRANT CREATE ON SCHEMA public TO teacher;

\q

### MySQL/MariaDB

sudo mysql

USE intendo;

CREATE USER student IDENTIFIED BY 'SomePassword';
CREATE USER teacher IDENTIFIED BY 'SomePassword';

GRANT SELECT ON intendo.* TO student;

GRANT SELECT ON intendo.* TO teacher;
GRANT CREATE ON intendo.* TO teacher;
GRANT INSERT ON intendo.* TO teacher;
GRANT ALTER ON intendo.* TO teacher;

exit;

### SQL Server

sqlcmd -S localhost -U SA

USE intendo;
GO;

CREATE LOGIN student WITH PASSWORD = 'SomePassword';
GO;
CREATE USER student FOR LOGIN student;
GO;
GRANT SELECT ON SCHEMA :: dbo TO student;
GO;

CREATE LOGIN teacher WITH PASSWORD = 'SomePassword';
GO;
CREATE USER teacher FOR LOGIN teacher;
GO;
GRANT SELECT ON SCHEMA :: dbo TO teacher;
GO;
GRANT CREATE TABLE TO teacher;
GO;
GRANT INSERT ON SCHEMA :: dbo TO teacher;
GO;
GRANT ALTER ON SCHEMA :: dbo TO teacher;
GO;
GRANT UPDATE ON SCHEMA :: dbo TO teacher;
GO;

# You'll also want to limit SQL Server memory
# This avoids strange crashes
sp_configure 'show advanced options', 1;
GO;
RECONFIGURE;
GO;
sp_configure 'max server memory', 1024;
GO;
RECONFIGURE;
GO;

## Allow external connections

# For this project I had to allow connections from outside the server.

### Postgres (version 14)

nano /etc/postgresql/14/main/postgresql.conf

# comment the line that says `listen_addresses = 'localhost'`
# add
listen_address = '*'
# below it

nano /etc/postgresql/14/main/pg_hba.conf

# paste these lines at the end
host    all             all     0.0.0.0/0       md5
host    all             all     :/0             md5

sudo systemctl restart postgresql
sudo ufw allow 5432/tcp

### MariaDB (i.e. MySQL replacement)

nano /etc/mysql/mariadb.conf.d/50-server.cnf`
# comment the line that says `bind-address = 127.0.0.1`

sudo systemctl restart mysql
sudo ufw allow 3306/tcp

### SQL Server

EXEC sys.sp_configure N'remote access', N'1';
GO;
RECONFIGURE WITH OVERRIDE;
GO;

sudo ufw allow 1433/tcp
sudo ufw allow 4022/tcp
sudo ufw allow 135/tcp
sudo ufw allow 1434/tcp
sudo ufw allow 1434/udp

## Changing database location

### PostgreSQL

sudo mkdir /postgres
sudo chown -R postgres:postgres /postgres
sudo systemctl stop postgresql
sudo rsync -av /var/lib/postgresql/ /postgres
sudo nano /etc/postgresql/14/main/postgresql.conf

# Then search `data_directory` and change the location to `/postgresql/14/main`. 

sudo systemctl restart postgresql

###  MySQL/MariaDB

sudo mkdir /mysql
sudo chown -R mysql:mysql /mysql
sudo systemctl stop mariadb
sudo cp -R -p /var/lib/mysql/* /mysql/
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# Then search `datadir` and set it to `/mariadb`. 

sudo systemctl start mariadb

### SQL Server

# ???
