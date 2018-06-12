FROM php:5-fpm

MAINTAINER Ayhan Kuru <ayhankuru@yandex.com.tr> 

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    git \
    cron \
    nginx \
    zlib1g-dev \
    mcrypt \
    php5-mcrypt \
    php5-fpm \
    php5-gd \
    php5-mysql \
    php5-imap \
    php5-json \
    php5-curl \
    libgmp10 \
    libgmp-dev \
    mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install \
    bcmath \
    gmp \
    mbstring \
    mysql \
    pdo \
    pdo_mysql \
    zip

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN cp /etc/php5/cli/php.ini /usr/local/etc/php/conf.d/php.ini

RUN php5enmod mcrypt

RUN mkdir -p /var/www/app

VOLUME /var/www/app
VOLUME /var/log/nginx

# Set up cron
ADD crontab /var/spool/cron/crontabs/www-data
RUN chown www-data.crontab /var/spool/cron/crontabs/www-data
RUN chmod 0600 /var/spool/cron/crontabs/www-data

COPY nginx.conf /etc/nginx/sites-available/default
RUN sed -i "s/request_terminate_timeout =.*/request_terminate_timeout=3600/g" /etc/php5/fpm/php.ini
RUN sed -i "s/default_socket_timeout =.*/default_socket_timeout=3600/g" /etc/php5/fpm/php.ini
RUN sed -i "s/max_execution_time =.*/max_execution_time=3600/g" /etc/php5/fpm/php.ini
RUN sed -i "s/cgi.fix_pathinfo=/cgi.fix_pathinfo=0#/g" /etc/php5/fpm/php.ini

COPY after.sh /usr/local/bin/after_work

WORKDIR /var/www/app

RUN /usr/local/bin/after_work

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD service php5-fpm start && nginx