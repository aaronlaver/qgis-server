FROM debian:buster-slim

ENV LANG=en_EN.UTF-8


RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        gnupg \
        ca-certificates \
        wget \
        locales \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    # Add the current key for package downloading - As the key changes every year at least
    # Please refer to QGIS install documentation and replace it with the latest one
    && wget -O - https://qgis.org/downloads/qgis-2020.gpg.key | gpg --import \
    && gpg --export --armor F7E06F06199EF2F2 | apt-key add - \
    && echo "deb https://qgis.org/debian-ltr buster main" >> /etc/apt/sources.list.d/qgis.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        qgis-server \
        spawn-fcgi \
        xauth \
        xvfb \
    && apt-get remove --purge -y \
        gnupg \
        wget \
    && rm -rf /var/lib/apt/lists/* 

RUN useradd -m qgis

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV QGIS_PREFIX_PATH /usr
ENV QGIS_SERVER_LOG_STDERR 1
ENV QGIS_SERVER_LOG_LEVEL 2

COPY cmd.sh /home/qgis/cmd.sh
RUN chmod -R 777 /home/qgis/cmd.sh
RUN chown qgis:qgis /home/qgis/cmd.sh

RUN apk update && apk upgrade
RUN apk --no-cache add git fcgi php7 php7-fpm \
    php7-tokenizer \
    php7-opcache \
    php7-session \
    php7-iconv \
    php7-intl \
    php7-mbstring \
    php7-openssl \
    php7-fileinfo \
    php7-curl \
    php7-json \
    php7-redis \
    php7-pgsql \
    php7-sqlite3 \
    php7-gd \
    php7-dom \
    php7-xml \
    php7-xmlrpc \
    php7-xmlreader \
    php7-xmlwriter \
    php7-simplexml \
    php7-phar \
    php7-gettext \
    php7-ctype \
    php7-zip \
    php7-ldap

WORKDIR /var/www

RUN ln -s /var/www/lizmap-web-client-3.4.2/lizmap/www/ /var/www/html/landmark

WORKDIR /var/www/lizmap-web-client-3.4.2/

RUN lizmap/install/set_rights.sh www-data www-data

WORKDIR lizmap/var/config

RUN cp lizmapConfig.ini.php.dist lizmapConfig.ini.php \
    && cp localconfig.ini.php.dist localconfig.ini.php

RUN php lizmap/install/installer.php

WORKDIR /var/www/lizmap-web-client-3.4.2/

RUN lizmap/install/set_rights.sh www-data www-data \
    && sudo apt-get install php7.0-pgsql

USER qgis
WORKDIR /home/qgis

ENTRYPOINT ["/tini", "--"]

CMD ["/home/qgis/cmd.sh"]

