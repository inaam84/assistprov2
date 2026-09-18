#!/bin/sh

set -e

echo "Preparing Laravel configuration..."

php artisan config:clear
php artisan config:cache

case "$1" in
    php-fpm)
        echo "Caching Laravel routes and views..."

        php artisan route:cache
        php artisan view:cache

        echo "Starting PHP-FPM..."
        exec "$@"
        ;;

    *)
        echo "Starting: $*"
        exec "$@"
        ;;
esac