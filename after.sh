#!/bin/bash
set -e
# After copying the repo of your project
# run this script to run composer update
# and preform some basic required actions.

# if dir exist, do not produce an error (|| true)
mkdir /var/www/app/bootstrap/cache || true
mkdir /var/www/app/storage/framework/views || true
chown www-data:www-data -R /var/www/app
chmod 755 -R /var/www/app/storage

if [[ -z "${COMPOSER_INIT}" ]]; then
    echo "running composer update"
    /usr/local/bin/composer install --no-scripts
else

if [[ -z "${MIGRATION_INIT}" ]]; then
    echo "running artisan migrate"
    php /var/www/app/artisan artisan migrate:refresh --seed
else


if [ "$HTTPS" == false ] ; then
	sed -i "s/fastcgi_param  HTTPS \"on\";/fastcgi_param  HTTPS \"off\";#/g" /etc/nginx/sites-available/default
fi

echo "starting php5-fpm && nginx"
service cron start
service php5-fpm start && nginx