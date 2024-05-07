ARG BASE_TAG=php8.2-alpine

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
        libjpeg-turbo \
        libzip-dev \
        freetype-dev \
        imagemagick-dev \
        imagemagick && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd ctype pdo pdo_pgsql pcntl exif zip intl && \
    rm /var/cache/apk/* && rm -rf /tmp/pear


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
