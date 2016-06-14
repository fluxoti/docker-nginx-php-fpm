#!/bin/bash

# creating a file with all environment variables
printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/\1="\2"/g' >> /etc/environment

# activating crontab file
crontab /var/spool/cron/crontabs/root

cd /var/www

# Reseting migrations if the env var is defined
if [ $RESET_MIGRATIONS = true ]
then
    php artisan migrate:reset --force
fi

# migrating the database
if [ $MIGRATE_DATABASE = true ]
then
    php artisan migrate --force
fi

# Seeding the database if the env var is defined
if [ $SEED_DATABASE = true ]
then
    php artisan db:seed
fi

# Setting  some PHP config
sed -i "s/error_reporting = .*/error_reporting = $PHP_ERROR_REPORTING/" /etc/php/7.0/cli/php.ini
sed -i "s/display_errors = .*/display_errors = $PHP_DISPLAY_ERRORS/" /etc/php/7.0/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = $PHP_MEMORY_LIMIT/" /etc/php/7.0/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = $PHP_TIMEZONE/" /etc/php/7.0/cli/php.ini

sed -i "s/error_reporting = .*/error_reporting = $PHP_ERROR_REPORTING/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = $PHP_DISPLAY_ERRORS/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = $PHP_MEMORY_LIMIT/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = $PHP_POST_MAX_SIZE/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = $PHP_TIMEZONE/" /etc/php/7.0/fpm/php.ini

# Adding new relic info
if [ -v NEWRELIC_LICENSE ]
then
    echo "php_value[newrelic.enabled] = on" >> /etc/php/7.0/fpm/pool.d/www.conf
    echo "php_value[newrelic.license] = \"$NEWRELIC_LICENSE\"" >> /etc/php/7.0/fpm/pool.d/www.conf
fi

if [ -v NEWRELIC_APPNAME ]
then
    echo "php_value[newrelic.appname] = \"$NEWRELIC_APPNAME\"" >> /etc/php/7.0/fpm/pool.d/www.conf
fi

exec /usr/sbin/php-fpm7.0 --nodaemonize --allow-to-run-as-root >> /var/log/php7.0-fpm.log 2>&1