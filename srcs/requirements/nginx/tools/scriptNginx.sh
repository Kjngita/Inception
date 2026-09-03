#!/bin/sh

set -e

echo "Starting Nginx..."

# Verify SSL certificate exists
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
	echo "ERROR: SSL certificate not found!"
	exit 1
fi

# Verify configuration
nginx -t

echo "Nginx is ready."

# Start Nginx in the foreground
exec nginx -g "daemon off;"