cd /etc/apache2/sites-available
# cp from to + edit
cd .. & cd sites-enabled
ln -s ../sites-available/mysite
sudo systemctl restart apache2
sudo certbot --apache -d databases.pacha.dev -d www.databases.pacha.dev
