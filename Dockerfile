# Dockerfile
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install MongoDB extension
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Set working directory
WORKDIR /var/www

# Install Symfony
RUN composer create-project symfony/skeleton:"7.1.*" symfony_app

# Move Symfony files to the current directory
RUN mv symfony_app/* symfony_app/.[!.]* ./ || true && rm -rf symfony_app

# Install additional Symfony packages
RUN composer require api -W

# Copy existing application contents
COPY . /var/www

# Set permissions
RUN chown -R www-data:www-data /var/www
