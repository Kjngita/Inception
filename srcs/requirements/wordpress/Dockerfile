FROM alpine:3.23

# Install required packages
RUN apk update && \
    apk add --no-cache \
        php84 \
        php84-fpm \
        php84-mysqli \
        php84-json \
        php84-curl \
        php84-gd \
        php84-mbstring \
        php84-xml \
        php84-xmlreader \
        php84-phar \
        php84-openssl \
        php84-iconv \
        php84-session \
        php84-zip \
        php84-fileinfo \
        php84-tokenizer \
        php84-bcmath \
        php84-exif \
        php84-simplexml \
        php84-dom \
        php84-posix \
        wget \
        unzip \
        mariadb-client \
        curl

# Create www-data user (Alpine doesn't have it by default)
RUN adduser -u 82 -D -S -G www-data www-data

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Download WordPress
RUN wget https://wordpress.org/latest.zip \
    && unzip latest.zip -d /var/www/ \
    && rm latest.zip \
    && chown -R www-data:www-data /var/www/wordpress

# Copy configuration
COPY ./conf/www.conf /etc/php84/php-fpm.d/www.conf

# Copy entrypoint script
COPY ./tools/scriptWP.sh /usr/local/bin/scriptWP.sh
RUN chmod +x /usr/local/bin/scriptWP.sh

# Set working directory
WORKDIR /var/www/wordpress

# Expose port for PHP-FPM
EXPOSE 9000

# Entrypoint
ENTRYPOINT ["/usr/local/bin/scriptWP.sh"]