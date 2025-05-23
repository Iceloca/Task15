FROM nginx:stable-alpine3.21

RUN addgroup -g 1001 nginxuser && \
    adduser -D -G nginxuser -u 1001 nginxuser && \
    apk add --no-cache nginx-mod-http-image-filter php && \
    rm -rf /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/nginx.conf
COPY www /var/www/html
COPY sites-enabled /etc/nginx/sites-enabled
COPY images /var/www/images
COPY scripts /home/nginxuser/scripts



RUN chown -R nginxuser:nginxuser /var/www /etc/nginx && \
    chmod -R 755 /var/www && \
    mkdir -p /var/cache/nginx/client_temp && \
    chown -R nginxuser:nginxuser /var/cache/nginx && \
    mkdir -p /var/log/nginx && \
    chown -R nginxuser:nginxuser /var/log/nginx && \
    chmod +x /home/nginxuser/scripts/start.sh /home/nginxuser/scripts/entrypoint.sh && \
    chown -R nginxuser:nginxuser /home/nginxuser/scripts

USER nginxuser

WORKDIR /home/nginxuser/scripts

EXPOSE 80 443

ENTRYPOINT ["./entrypoint.sh"]
