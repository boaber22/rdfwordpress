#!/bin/bash
# variable will be populated by terraform template
db_admin_username=${db_admin_username}
db_admin_password=${db_admin_password}
db_wp_username=${db_wp_username}
db_wp_password=${db_wp_password}
db_name=${db_name}
db_RDS=${db_RDS}

# *****************install LAMP Server***************************
yum update -y
#install apache server and mysql client
yum install -y httpd
yum install -y mysql
 

#Connect to RDS instance using mySQL and create a user that will be used with Wordpress

mysql -h $db_RDS -u $db_admin_username -p$db_admin_password  <<EOF
    CREATE USER '$db_wp_username' IDENTIFIED BY '$db_wp_password';
    GRANT ALL PRIVILEGES ON $db_name.* TO '$db_wp_username';
    FLUSH PRIVILEGES;
    Exit
EOF


#install maria db and php from Amazon Linux Extras

amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}

systemctl restart php-fpm.service

systemctl start httpd


# Change OWNER and permission of directory /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;


#**********************Installing Wordpress ********************************* 
# Download wordpress package and extract
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
# Create wordpress configuration file and update database value
cd /var/www/html
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$db_name/g" wp-config.php
sed -i "s/username_here/$db_wp_username/g" wp-config.php
sed -i "s/password_here/$db_wp_password/g" wp-config.php
sed -i "s/localhost/$db_RDS/g" wp-config.php
cat <<EOF >>/var/www/html/wp-config.php
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
EOF


# Change permission of /var/www/html/
chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html

#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

#Make apache  autostart and restart apache
systemctl enable  httpd.service
systemctl restart httpd.service
echo WordPress Installed

