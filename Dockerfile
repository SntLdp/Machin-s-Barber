FROM php:8.4-apache

# Eliminar MPMs y dejar únicamente prefork
RUN rm -f /etc/apache2/mods-enabled/mpm_*.load \
          /etc/apache2/mods-enabled/mpm_*.conf \
    && a2enmod mpm_prefork \
    && a2enmod rewrite

# Dependencias
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

WORKDIR /var/www/html

# Copiar proyecto Laravel
COPY . .

# Instalar dependencias PHP
RUN composer install \
    --optimize-autoloader \
    --no-dev \
    --no-interaction \
    --no-progress

# Configurar Apache para Laravel
RUN sed -i 's#DocumentRoot .*#DocumentRoot /var/www/html/public#' \
    /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/AllowOverride None/AllowOverride All/g' \
    /etc/apache2/apache2.conf

# Permisos de Laravel
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Comprobar Apache
RUN apachectl -t

EXPOSE 80