# Gunakan image PHP 8.2 FPM
FROM php:8.2-fpm

# Install dependensi sistem
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip unzip curl git nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Salin composer dari image resmi
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Salin semua file project
COPY . .

# Install dependency backend Laravel
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

CMD php artisan key:generate \
 && php artisan storage:link \
 && php artisan project:init \
 && php artisan project:update

# Install dependency frontend (Vite) dan build asset
RUN npm install && npm run build

# Bersihkan cache dan siapkan symbolic link
RUN php artisan config:clear \
 && php artisan view:clear \
 && php artisan optimize:clear \
 && php artisan permission:cache-reset || true

# Buat direktori yang dibutuhkan Livewire dan set permission
RUN mkdir -p storage/framework/livewire-tmp \
 && chmod -R 775 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

# Atur batas upload file
RUN echo "upload_max_filesize=10M\npost_max_size=12M" > /usr/local/etc/php/conf.d/uploads.ini

# Buka port default Laravel
EXPOSE 8000

# Jalankan Laravel: key, migrate, storage link, lalu serve
CMD php artisan serve --host=0.0.0.0 --port=8000
