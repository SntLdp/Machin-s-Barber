FROM php:8.4-apache

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Dependencias y extensiones PHP
RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        zip \
        libzip-dev \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Laravel en /public
RUN sed -i 's#DocumentRoot .*#DocumentRoot /var/www/html/public#' \
    /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/AllowOverride None/AllowOverride All/g' \
    /etc/apache2/apache2.conf

WORKDIR /var/www/html