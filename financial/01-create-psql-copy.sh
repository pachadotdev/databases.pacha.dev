cd ~
sudo apt install sbcl unzip libsqlite3-dev gawk curl make freetds-dev libzip-dev
curl -fsSLO https://github.com/dimitri/pgloader/archive/v3.6.2.tar.gz
tar xvf v3.6.2.tar.gz
cd pgloader-3.6.2/
make pgloader
sudo mv ./build/bin/pgloader /usr/local/bin/
pgloader --version

sudo -i -u postgres 
psql
CREATE DATABASE financial;
\q

psql -d financial

GRANT CONNECT ON DATABASE financial TO student;
GRANT USAGE ON SCHEMA public TO student;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO student;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO student;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO student;
REVOKE CREATE ON SCHEMA public FROM public;

GRANT CONNECT ON DATABASE financial TO teacher;
GRANT USAGE ON SCHEMA public TO teacher;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO teacher;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO teacher;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO teacher;
GRANT CREATE ON SCHEMA public TO teacher;

\q

exit
