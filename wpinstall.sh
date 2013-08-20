#!/bin/bash
 
# Written by Oliver M. Grech - olivermgrech.com

echo "MySQL Host:"
read mysqlhost
export mysqlhost


echo "Database Admin Username:"
read dbAdminUser
export dbAdminUser



echo "Database Admin Password:"
read dbAdminPass
export dbAdminPass


echo "New (WP) Database Name"
read wpNewDBName
export wpNewDBName

mysqladmin -u$dbAdminUser -p$dbAdminPass create $wpNewDBName

echo "New (WP) Database User"
read wpNewDBUser
export wpNewDBUser

echo "New (WP) Database Password"
read wpNewDBPass
export wpNewDBPass

mysql -u$dbAdminUser -p$dbAdminPass $wpNewDBName<<EOFMYSQL
CREATE USER '$wpNewDBUser'@'$mysqlhost' IDENTIFIED BY '$wpNewDBPass';
GRANT ALL PRIVILEGES ON $wpNewDBName . * TO '$wpNewDBUser'@'$mysqlhost';
FLUSH PRIVILEGES;
EOFMYSQL
 
# DB Variables

 
 
# WP Variables
echo "Site Title:"
read wptitle
export wptitle
 
echo "Admin Username:"
read wpuser
export wpuser
 
echo "Admin Password:"
read wppass
export wppass
 
echo "Admin Email"
read wpemail
export wpemail
 
# Site Variables
echo "Site URL (ie, www.youraddress.com):"
read siteurl
export siteurl
 
# Site Variables
echo "Install Path (/var/www/example.com)"
read installPath
export installPath
 
wget http://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
rm latest.tar.gz
mkdir $installPath
mv wordpress/* $installPath
rmdir wordpress

 
# Grab our Salt Keys
wget -O /tmp/wp.keys https://api.wordpress.org/secret-key/1.1/salt/
 
# Butcher our wp-config.php file
sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$wpNewDBName"/" -e "s/username_here/"$wpNewDBUser"/" -e "s/password_here/"$wpNewDBPass"/" $installPath/wp-config-sample.php > $installPath/wp-config.php
sed -i '/#@-/r /tmp/wp.keys' $installPath/wp-config.php
sed -i "/#@+/,/#@-/d" $installPath/wp-config.php
 
# Run our install ...
wget --post-data="weblog_title=$wptitle&user_name=$wpuser&admin_password=$wppass&admin_password2=$wppass&admin_email=$wpemail" http://$siteurl/wp-admin/install.php?step=2

rm /tmp/wp.keys