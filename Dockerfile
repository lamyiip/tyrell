# Dockerfile for Playing Card Distribution System
# Base image: PHP 7.4 with Apache
FROM php:7.4-apache

# Set working directory
WORKDIR /var/www/html

# Install required PHP extensions if needed
# RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite (if needed for routing)
RUN a2enmod rewrite

# Copy application files
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
