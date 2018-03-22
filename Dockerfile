FROM alpine:latest
MAINTAINER realies <docker@reali.es>
RUN apk update && apk upgrade && \
 apk add --virtual build-dependencies curl && \
 apk add mariadb mariadb-client nginx php7 php7-fpm php7-gd php7-json php7-mysqli php7-zlib supervisor && \
 echo "* Downloading latest stable WordPress release..." && \
 curl -fL# http://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz && \
 echo "* Extracting..." && \
 mkdir -p /data/www && \
 tar -xf /tmp/wordpress.tar.gz --strip-components=1 -C /data/www && \
 echo "* Setting users and permissions..." && \
 adduser -D -u 1000 -g 'www' www && \
 chown -R www:www /data/www && \
 find /data/www -type d -exec chmod 755 {} \; && \
 find /data/www -type f -exec chmod 644 {} \; && \
 find /data/www/wp-content -type d -exec chmod 775 {} \; && \
 find /data/www/wp-content -type f -exec chmod 664 {} \; && \
 chown -R www:www /var/lib/nginx /var/tmp/nginx && \
 sed -ri 's/^(user|group) = nobody/\1 = www/g' /etc/php7/php-fpm.d/www.conf && \
 sed -i 's/pm = dynamic/pm = ondemand/' /etc/php7/php-fpm.d/www.conf && \
 sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 200M/g" /etc/php7/php.ini && \
 sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 200M/g" /etc/php7/php.ini && \
 sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
 sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 200m/" /etc/nginx/nginx.conf && \
 mkdir -p /data/mariadb /run/mysqld && \
 chown -R mysql:mysql /data/mariadb /run/mysqld && \
 echo "* Cleaning up..." && \
 apk del build-dependencies && \
 rm -rf /var/cache/apk/* && rm /tmp/wordpress.tar.gz
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY init.sh /init.sh
ENTRYPOINT /init.sh
