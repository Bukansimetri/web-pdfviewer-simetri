# Gunakan image PHP 8.3 FPM
FROM php:8.3-fpm

# Install dependensi sistem dan ekstensi PHP
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
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

# Set direktori kerja
WORKDIR /var/www

# Salin semua file project
COPY . .

# Install dependency backend Laravel
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Build frontend (Vite)
RUN npm install && npm run build

# Bersihkan cache
RUN php artisan config:clear \
 && php artisan view:clear \
 && php artisan cache:clear \
 && (php artisan optimize:clear || true)

# Siapkan direktori Livewire & permission
RUN mkdir -p storage/framework/livewire-tmp \
 && chmod -R 775 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

# Atur limit upload file
RUN echo "upload_max_filesize=10M\npost_max_size=12M" > /usr/local/etc/php/conf.d/uploads.ini

# Buka port Laravel
EXPOSE 8000

# Jalankan Laravel + Shield + Seeder + Serve
CMD php artisan key:generate && \
    php artisan storage:link && \
    php artisan optimize:clear && \
    php artisan serve --host=0.0.0.0 --port=8000
