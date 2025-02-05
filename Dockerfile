ARG ALPINE_VERSION=3.16
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Tim de Pater <code@trafex.nl>"
LABEL Description="Lightweight container with Nginx 1.22 & PHP 8.2 based on Alpine Linux. With Laravel support by @hidde.me"
# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  redis \
  php82 \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fpm \
  php82-gd \
  php82-intl \
  php82-mbstring \
  php82-pdo \
  php82-pgsql \
  php82-pdo_pgsql \
  php82-opcache \
  php82-openssl \
  php82-phar \
  php82-session \
  php82-xml \
  php82-xmlreader \
  php82-xmlwriter \
  php82-fileinfo \
  php82-simplexml \
  php82-tokenizer \
  php82-exif \
  php82-pcntl \
  php82-posix \
  php82-redis \
  supervisor
# Create symlink so programs depending on `php` still function
RUN ln -s /usr/bin/php82 /usr/bin/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY config/php.ini /etc/php82/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

COPY --from=hipages/php-fpm_exporter /php-fpm_exporter /usr/bin/php-fpm_exporter
RUN chmod +x /usr/bin/php-fpm_exporter

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Expose php-fpm_exporter port
EXPOSE 9253

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

# Install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer