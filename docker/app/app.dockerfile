FROM php:7.4-apache

LABEL maintainer="PatricNox <hello@patricnox.info>"

# Extract the PHP source
RUN docker-php-source extract

# Install libs
RUN apt-get update \
    && apt-get install -y \
        git \
        libfontconfig \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libpq-dev \
        libxrender1 \
        default-mysql-client \
        unzip \
        wget \
        zip \
        libxml2-dev \
        libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
        bcmath \
        opcache \
        pdo \
        pdo_mysql \
        zip \
        soap

# Install GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Copy the development PHP config from the PHP source
RUN cp /usr/src/php/php.ini-development /usr/local/etc/php/php.ini

# Delete the PHP source
RUN docker-php-source delete

# Copy the PHP configuration
COPY app/php/app.ini /usr/local/etc/php/conf.d/

# Copy the Apache configuration
COPY app/apache/app.conf /etc/apache2/sites-available/000-default.conf

# Enable Apache mods
RUN a2enmod rewrite

# Fix permissions
RUN chown -R www-data:www-data /var/www

# Set working directory
WORKDIR /var/www/html

# Install NodeJS with NPM
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install --yes nodejs

# Install composer
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

# Speed up composer downloads
USER www-data
RUN /usr/bin/composer global require hirak/prestissimo
USER root
