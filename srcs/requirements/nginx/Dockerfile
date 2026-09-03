FROM alpine:3.23

# Install Nginx and OpenSSL
RUN apk update && \
	apk add --no-cache \
		nginx \
		openssl

# Create SSL directory and generate self-signed certificate
RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/C=FI/ST=SparkleSlide/L=PinaColada/O=PompompurinParty/CN=gita.42.fr"

# Copy Nginx configuration
COPY ./conf/nginx.conf /etc/nginx/http.d/default.conf

# Copy entrypoint script
COPY ./tools/scriptNginx.sh /usr/local/bin/scriptNginx.sh
RUN chmod +x /usr/local/bin/scriptNginx.sh

# Create necessary directories
RUN mkdir -p /var/www/html

# Expose port 443 (HTTPS)
EXPOSE 443

# Entrypoint
ENTRYPOINT ["/usr/local/bin/scriptNginx.sh"]