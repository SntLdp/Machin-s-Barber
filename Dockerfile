# =========================
# Etapa 1: Compilar Vite
# =========================
FROM node:22-alpine AS frontend

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build


# =========================
# Etapa 2: Laravel + Apache
# =========================
FROM php:8.4-apache

# Dependencias del sistema
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

# Copiar proyecto
COPY . .

# Copiar los archivos compilados de Vite
COPY --from=frontend /app/public/build ./public/build

# Instalar dependencias Laravel
RUN composer install \
    --optimize-autoloader \
    --no-dev \
    --no-interaction \
    --no-progress

# Configurar Apache
RUN sed -i 's#DocumentRoot .*#DocumentRoot /var/www/html/public#' \
    /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/AllowOverride None/AllowOverride All/g' \
    /etc/apache2/apache2.conf

# Apache
RUN rm -f /etc/apache2/mods-enabled/mpm_*.load \
    /etc/apache2/mods-enabled/mpm_*.conf \
    && a2enmod mpm_prefork \
    && a2enmod rewrite

# Permisos Laravel
RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["bash", "-c", "rm -f /etc/apache2/mods-enabled/mpm_*.load /etc/apache2/mods-enabled/mpm_*.conf && a2enmod mpm_prefork rewrite && exec apache2-foreground"]