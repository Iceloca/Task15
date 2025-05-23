FROM php:8.2-apache

RUN groupadd -g 1001 apacheuser && useradd -m -u 1001 -g apacheuser apacheuser

RUN mkdir -p /usr/local/apache2/logs/&& \
    chown -R apacheuser:apacheuser /usr/local/apache2/logs

# Копируем HTML-контент
COPY www/ /var/www/html/

COPY ports.conf /etc/apache2/ports.conf

USER apacheuser


EXPOSE 8080
