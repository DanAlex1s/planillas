FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    vim \
    git \
    curl \
    libicu-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip  \
    && docker-php-ext-install zip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Сonfigure PHP extensions
RUN docker-php-ext-configure intl

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif intl pcntl bcmath gd zip

# Set the upload size limit
RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 100M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 100M;" >> /usr/local/etc/php/conf.d/uploads.ini

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

COPY . /var/www

RUN chown -R www-data:www-data /var/www

# Run composer install
RUN composer install

RUN php artisan key:generate
