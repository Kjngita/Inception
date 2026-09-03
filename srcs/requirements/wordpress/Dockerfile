FROM alpine:3.23

# Essential PHP extensions for WordPress
RUN apk add --no-cache \
	php84 \
	php84-fpm \
	php84-mysqli \
	php84-curl \
	php84-gd \
	php84-mbstring \
	php84-xml \
	php84-zip \
	php84-phar \
	php84-openssl \
	mariadb-client \
	curl \
	unzip

# Create www-data user
RUN adduser -S -D -H -G www-data www-data

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM config
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Copy entrypoint script
COPY ./tools/scriptWP.sh /usr/local/bin/scriptWP.sh
RUN chmod +x /usr/local/bin/scriptWP.sh

# Set working directory
WORKDIR /var/www/html

# Expose port for PHP-FPM
EXPOSE 9000

HEALTHCHECK --start-period=60s --interval=30s --timeout=10s --retries=3 \
	CMD wp --allow-root --path=/var/www/html core is-installed || exit 1

# Entrypoint
ENTRYPOINT ["/usr/local/bin/scriptWP.sh"]