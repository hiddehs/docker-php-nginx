#ARG BASE_TAG=5.0.3-php8.2-alpine
ARG BASE_TAG=6.0-php8.4-alpine
#php8.2-alpine -> = 5.1 swoole = alpine 3.19 = php 8.2 rc 18 with psql bug

# https://hub.docker.com/r/phpswoole/swoole
FROM phpswoole/swoole:$BASE_TAG
WORKDIR /var/www/html

RUN set -ex \
    && apk update \
    && apk --no-cache add \
        supervisor \
        nginx \
        nano \
        curl \
        autoconf \
        curl-dev \
        openssl \
        postgresql \
        postgresql-dev \
        jpeg-dev \
        libpng-dev \
        libwebp-dev \
        libjpeg-turbo \
        libzip-dev \
        freetype-dev \
        imagemagick-dev \
        imagemagick && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd ctype pdo pdo_pgsql pcntl exif zip intl && \
    apk del autoconf && \
    rm -rf /var/cache/apk/* /tmp/pear /usr/src/*

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
