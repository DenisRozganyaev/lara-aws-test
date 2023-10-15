FROM php:8.2-apache

# Встановлюємо необхідні розширення PHP
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip pdo pdo_mysql

# Встановлюємо Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y nodejs npm

# Увімкнення модулів Apache
RUN a2enmod rewrite

COPY .docker/apache/default.conf /etc/apache2/sites-available/000-default.conf

# Робочий каталог в контейнері
WORKDIR /var/www/html

# Копіюємо файли Laravel
COPY . .

# Встановлюємо залежності Laravel
RUN composer install --no-dev --optimize-autoloader

# Виконуємо міграції та інші команди за необхідності
#RUN php artisan migrate
#RUN php artisan config:cache
#RUN php artisan route:cache
RUN php artisan storage:link

# Встановлюємо права доступу
RUN chown -R www-data:www-data /var/www/html/storage

# Забороняємо вивід помилок на екран
RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "log_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "error_log = /var/log/php/php_error.log" >> /usr/local/etc/php/php.ini

# Вказуємо порт Apache
EXPOSE 80

# Запускаємо Apache
CMD ["apache2-foreground"]
