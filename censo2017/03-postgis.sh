sudo apt update

sudo apt install gnupg2
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list

sudo apt update
sudo apt install postgis postgresql-14-postgis-3

sudo -i -u postgres
psql -d censo2017
CREATE EXTENSION postgis;
\q
exit

