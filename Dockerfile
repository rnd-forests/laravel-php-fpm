FROM php:7.2-fpm

MAINTAINER Nguyen Ngoc Vinh <ngocvinh.nnv@gmail.com>

ENV TERM xterm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libxml2-dev \
    libmcrypt-dev \
    vim \
    zlib1g-dev libicu-dev g++ \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

RUN docker-php-ext-configure intl

RUN pecl channel-update pecl.php.net \
    && pecl install mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt

RUN docker-php-ext-install \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    intl \
    soap \
    zip

RUN usermod -u 1000 www-data

WORKDIR /var/www/app

ADD ./conf/php.ini /usr/local/etc/php/conf.d
ADD ./conf/www.conf /usr/local/etc/php-fpm.d/

COPY ./xdebug.ini /tmp/
RUN cat /tmp/xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000
CMD ["php-fpm"]
