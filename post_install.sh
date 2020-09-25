#!/bin/sh

# clone release branch
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch /usr/local/www/bookstack

# Enable autostart for php, nginx and mysql
sysrc -f /etc/rc.conf nginx_enable="YES"
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf php_fpm_enable="YES"

# Setup php-fpm
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
sed -i '' 's|listen = 127.0.0.1:9000|listen = /var/run/php-fpm.sock|' /usr/local/etc/php-fpm.d/www.conf
sed -i '' 's/;listen.owner = www/listen.owner = www/' /usr/local/etc/php-fpm.d/www.conf
sed -i '' 's/;listen.group = www/listen.group = www/' /usr/local/etc/php-fpm.d/www.conf
sed -i '' 's/;listen.mode = 0660/listen.mode = 0660/' /usr/local/etc/php-fpm.d/www.conf
sed -i '' 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /usr/local/etc/php.ini

# Start the service
service nginx start
service php-fpm start
service mysql-server start

# Configure mysql
DB_PASS=$(openssl rand -base64 16)
mysql -u root -e "CREATE DATABASE bookstack;"
mysql -u root -e "CREATE USER 'bookstack'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';"
mysql -u root -e "GRANT ALL ON bookstack.* TO 'bookstack'@'localhost';FLUSH PRIVILEGES;"

# Install bookstack
cd /usr/local/www/bookstack
composer install --no-dev
cp .env.example .env

# Update env
sed -i '' 's|DB_DATABASE=.*$|DB_DATABASE=bookstack|' .env
sed -i '' 's|DB_USERNAME=.*$|DB_USERNAME=bookstack|' .env
sed -i '' "s|DB_PASSWORD=.*\$|DB_PASSWORD=$DB_PASS|" .env

# Set proper permissions
chown -R www:www /usr/local/www/bookstack
chmod -R 755 bootstrap/cache public/uploads storage

# Regenerate key and install tables
php artisan key:generate --no-interaction --force
php artisan migrate --no-interaction --force

# Reload configs
service php-fpm restart
service nginx reload

echo "DATABASE_NAME=bookstack" >> /root/PLUGIN_INFO
echo "DB_USERNAME=bookstack" >> /root/PLUGIN_INFO
echo "DB_PASSWORD=${$DB_PASS}" >> /root/PLUGIN_INFO
