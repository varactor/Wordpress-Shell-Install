#!/bin/bash
 
# Written by Oliver M. Grech - olivermgrech.com

# Modified by Lucas de la Fuente - lucasdelafuente.com
# Usage: ./wpinstall.sh db_name db_user dbpass shell_user "My Site Title" "www.mysite.com" "/home/user/public_html"
# [1] db_name: new database name
# [2] db_user: DB user, and wordpress admin
# [3] dbpass: new database user password
# [4] shell_user: shell user to chown files ( username or www-data )
# [5] site title: Site title, between quotes
# [6] site url: without http://, like www.example.com
# [7] install path: like "/home/user/public_html", quoted if some space in between

if [ $# -ne 7 ]; then
    echo $0: usage: ./wpinstall.sh db_name db_user dbpass shell_user "My Site Title" "www.mysite.com" "/home/user/public_html"
    exit 1
fi

mysqlhost="localhost"
dbAdminUser="root"
dbAdminPass="root_pass"
wpemail="your@email.com"
wpNewDBName=$1
wpNewDBUser=$2
wpNewDBPass=$3
shellUser=$4
wptitle=$5
wpuser=$2
wppass=$3
siteurl=$6
installPath=$7

mysqladmin -u$dbAdminUser -p$dbAdminPass create $wpNewDBName
clear

mysql -u$dbAdminUser -p$dbAdminPass $wpNewDBName<<EOFMYSQL
CREATE USER '$wpNewDBUser'@'$mysqlhost' IDENTIFIED BY '$wpNewDBPass';
GRANT ALL PRIVILEGES ON $wpNewDBName . * TO '$wpNewDBUser'@'$mysqlhost';
FLUSH PRIVILEGES;
EOFMYSQL
clear
 
wget http://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
rm latest.tar.gz
mkdir $installPath
mv wordpress/* $installPath
rmdir wordpress
clear

# Auto-download plugins, if needed:

# Sitemap Generator, uncomment or reuse block for other plugins
# echo "Fetching Google Sitemap Generator plugin...";
# wget --quiet http://downloads.wordpress.org/plugin/google-sitemap-generator.zip;	
# unzip -q  google-sitemap-generator.zip;	
# mv google-sitemap-generator $installPath/wp-content/plugins/
# rm google-sitemap-generator.zip;	

# Grab our Salt Keys
wget -O /tmp/wp.keys https://api.wordpress.org/secret-key/1.1/salt/
 
# Butcher our wp-config.php file
sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$wpNewDBName"/" -e "s/username_here/"$wpNewDBUser"/" -e "s/password_here/"$wpNewDBPass"/" $installPath/wp-config-sample.php > $installPath/wp-config.php
sed -i '/#@-/r /tmp/wp.keys' $installPath/wp-config.php
sed -i "/#@+/,/#@-/d" $installPath/wp-config.php
sed -e "s/'wp_'/'ws_'/" $installPath/wp-config.php

# change files ownership and group
chown -R $shellUser:$shellUser $installPath
 
# Run our install ...
wget --post-data="weblog_title=$wptitle&user_name=$wpuser&admin_password=$wppass&admin_password2=$wppass&admin_email=$wpemail" http://$siteurl/wp-admin/install.php?step=2
clear

rm /tmp/wp.keys

echo "."
echo "."
echo "WP Site installed"
