FROM alpine:3.19

RUN apk update && apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-json php82-curl \
    php82-dom php82-exif php82-fileinfo php82-mbstring \
    php82-openssl php82-xml php82-zip php82-phar \
    php82-tokenizer php82-session php82-iconv \
    curl bash mariadb-client

# Increase PHP memory limit for WP-CLI
RUN echo "memory_limit=512M" > /etc/php82/conf.d/memory.ini

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create PHP-FPM directories
RUN mkdir -p /var/www/html /run/php

# Copy configuration and script
COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY ./tools/script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/script.sh"]