FROM php:8.4-fpm-alpine

RUN apk add --no-cache \
    bash \
    git \
    unzip \
    libzip-dev \
    oniguruma-dev \
    $PHPIZE_DEPS

RUN docker-php-ext-install \
    pdo_mysql \
    bcmath \
    mbstring \
    opcache

RUN pecl install redis \
    && docker-php-ext-enable redis \
    && apk del $PHPIZE_DEPS

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY docker/php/php.ini /usr/local/etc/php/conf.d/php.ini

WORKDIR /var/www/html

# Install production Composer dependencies.
# Scripts are disabled because artisan isn't available yet.
COPY composer.json composer.lock ./

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev \
    --no-scripts

# Copy Laravel application
COPY . .

# Remove any package manifests generated on the host
# and regenerate them using the production dependencies.
RUN rm -f bootstrap/cache/packages.php bootstrap/cache/services.php

RUN php artisan package:discover --ansi

RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Laravel writable directories
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh    

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm"]