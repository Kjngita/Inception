FROM alpine:3.23

# Install MariaDB and MariaDB client
RUN apk update && \
    apk add --no-cache mariadb mariadb-client

# Create necessary directories and set permissions
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy and setup MariaDB config
COPY ./conf/configMaria /etc/my.cnf.d/configMaria
RUN chmod 644 /etc/my.cnf.d/configMaria

# MariaDB listens on 3306 by default, good practice to expose
# but actual port mapping is in docker-compose.yml
EXPOSE 3306

HEALTHCHECK --start-period=30s --interval=10s --timeout=5s --retries=5 \
    CMD sh -c "mariadb -u root -p$(cat /run/secrets/mysql_root_pw) -e 'SELECT 1' || exit 1"

# Copy, setup and run startup script for MariaDB
COPY ./tools/scriptMaria.sh /usr/local/bin/scriptMaria.sh 
RUN chmod +x /usr/local/bin/scriptMaria.sh
ENTRYPOINT ["/usr/local/bin/scriptMaria.sh"]