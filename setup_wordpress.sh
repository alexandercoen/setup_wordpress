#!/bin/bash

### Install LAMP, WordPress
apt-get -y  install apache2 apache2-utils
systemctl enable apache2
systemctl start apache2

apt-get -y install php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
/etc/init.d/apache2 restart

apt install -y curl
apt install -y zip
apt-get remove mariadb-server
apt-get remove --auto-remove mariadb-server
apt-get purge mariadb-server
apt-get purge --auto-remove mariadb-server

apt-get -y install dirmngr
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
apt-get update
MYSQL_ROOT=root
read  MYSQL_ROOT
echo "Enter the password for DB_USER root "
read MYSQL_PASS
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASS"
apt-get -y install mariadb-server
#########################################################################################################################################
echo "Enter the Name for DB "
read DBNAME
mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -e " CREATE DATABASE  $DBNAME"
mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -e " GRANT ALL PRIVILEGES ON $DBNAME.* TO '$MYSQL_ROOT'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -e " FLUSH PRIVILEGES;"
#########################################################################################################################################
service apache2 restart
service mysql restart > /dev/null
#####

## move the WP System to /var/www/html/
PATHWP="/root/wordpress.zip"
echo "Enter the Word Press Version like  '4.6' "
read WPVersion
curl https://de.wordpress.org/wordpress-$WPVersion-de_DE.zip -o $PATHWP
unzip $PATHWP
cd /root/wordpress
mv /root/wordpress /root/html
cp -r /root/html/* /var/www/html

chown -R www-data:www-data /var/www/html/
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i -e "s/datenbankname_hier_einfuegen/$DBNAME/g" /var/www/html/wp-config.php
sed -i -e "s/benutzername_hier_einfuegen/$MYSQL_ROOT/g" /var/www/html/wp-config.php
sed -i -e "s/passwort_hier_einfuegen/$MYSQL_PASS/g" /var/www/html/wp-config.php
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;


echo "Installation complete!!!!!!  Enjoy!!!!"
####
