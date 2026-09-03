#!/bin/sh

# Read root password from secret
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_pw)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_pw)

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB data directory..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Run the temporary MariaDB in the background with no networking
	# and continue with the script
	echo "Starting temporary MariaDB for setup..."
	mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
	DB_PID=$!

	# Wait for MariaDB socket file to appear
	echo "Waiting for MariaDB socket..."
	while [ ! -S /run/mysqld/mysqld.sock ]; do
		sleep 1
	done
	echo "MariaDB socket is ready!"

	echo "Setting up database and users..."
	# Root password
	mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

	# Create database and user
	mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
	mariadb -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
	echo "Database setup complete!"
	
	# Shut down the temporary MariaDB
	kill $DB_PID
	# Pause the script until temp MariaDB fully exits
	wait $DB_PID
fi

echo "Starting MariaDB..."
# Replace current shell process with the final MariaDB
# With exec, MariaDB becomes PID 1 in the container & receives signals directly
exec mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking=0 --port=3306 --bind-address=0.0.0.0