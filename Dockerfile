FROM php:7.4-fpm-alpine

LABEL maintainer="rrvenn@proton.me"

ENV SSH_PORT=8022 \
    GIT_USER=git \
    MYSQL_PORT=3306 \
    PROTOCOL=http

EXPOSE 8022 80 443

# Install runtime packages and build dependencies, then install PHP extensions.
# Uses the official PHP helper tools (`docker-php-ext-*`) and PECL for extensions like APCu.
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev libjpeg-turbo-dev libpng-dev zlib-dev libzip-dev oniguruma-dev libxml2-dev curl-dev openssl-dev \
    && apk add --no-cache \
        freetype libjpeg-turbo libpng zlib libzip oniguruma git mercurial subversion sudo ca-certificates wget \
        nginx supervisor openssh python3 py3-pygments procps \
    && pecl channel-update pecl.php.net \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd pdo_mysql mysqli mbstring zip opcache \
    && if [ -f /usr/libexec/git-core/git-http-backend ]; then ln -sf /usr/libexec/git-core/git-http-backend /usr/bin/git-http-backend; elif [ -f /usr/lib/git-core/git-http-backend ]; then ln -sf /usr/lib/git-core/git-http-backend /usr/bin/git-http-backend; fi \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Download phorge sources
RUN mkdir -p /var/www/phorge/
RUN git clone https://we.phorge.it/source/arcanist.git /var/www/phorge/arcanist \
    && git clone https://we.phorge.it/source/phorge.git /var/www/phorge/phorge

# copy nginx config (the repo provides a custom nginx.conf)
COPY ./configs/nginx-ph.conf /etc/nginx/sites-available/phorge.conf
COPY ./configs/nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled \
    && ln -sf /etc/nginx/sites-available/phorge.conf /etc/nginx/sites-enabled/phorge.conf

# copy ssh key generation
COPY ./configs/regenerate-ssh-keys.sh /regenerate-ssh-keys.sh

# copy PHP config into locations used by the official PHP images
COPY ./configs/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./configs/php.ini /usr/local/etc/php/php.ini
COPY ./configs/php-fpm.conf /usr/local/etc/php-fpm.conf
RUN mkdir -p /run/php && chown www-data:www-data /run/php

# copy supervisord config and startup script
COPY ./configs/supervisord.conf /etc/supervisord.conf
COPY ./scripts/startup.sh /startup.sh
RUN chmod +x /startup.sh

RUN mkdir -p /var/repo/

CMD [ "/startup.sh" ]
