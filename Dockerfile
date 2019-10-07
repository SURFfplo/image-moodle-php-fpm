FROM php:7.1-fpm-alpine

LABEL Description="image for moodle"
LABEL image="moodle-php-fpm"
LABEL versie="0.1"
LABEL datum="2019 10 01"

ARG DOCUMENT_ROOT=/var/www/html
ARG MY_TZ=Europe/Amsterdam

ENV WEB_DOCUMENT_ROOT=$DOCUMENT_ROOT
ENV WEB_MY_TZ=${MY_TZ}

RUN mkdir /var/moodledata \
&& mkdir /var/moodle_behat_output \
&& chmod 777 /var/moodledata

RUN apk update && apk add --no-cache bash postgresql-dev icu-dev zlib-dev libpng-dev libxml2-dev libxslt-dev \
    $PHPIZE_DEPS \
    && docker-php-ext-configure pgsql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pgsql pdo_pgsql zip gd soap xmlrpc opcache xsl intl exif

# Config
COPY conf/php-fpm-entrypoint.sh /entrypoint.sh
    
# change ownership 
RUN apk --no-cache add shadow && usermod -u 1000 www-data

WORKDIR ${WEB_DOCUMENT_ROOT}

# add my entrypoint, but keep php entrypoint and cmd as well
ENTRYPOINT ["/entrypoint.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
