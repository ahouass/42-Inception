#!/bin/bash
set -e

DOMAIN_NAME="${DOMAIN_NAME:-localhost}"
WORDPRESS_HOST="${WORDPRESS_HOST:-wordpress}"
WORDPRESS_PORT="${WORDPRESS_PORT:-9000}"

if [ ! -f "/etc/nginx/ssl/server.crt" ] || [ ! -f "/etc/nginx/ssl/server.key" ]; then
    echo "Generating self-signed TLS certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=MA/ST=Tanger/L=Tanger/O=42/OU=42/CN=${DOMAIN_NAME}" \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt
fi

sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf
sed -i "s/WORDPRESS_HOST_PLACEHOLDER/${WORDPRESS_HOST}/g" /etc/nginx/nginx.conf
sed -i "s/WORDPRESS_PORT_PLACEHOLDER/${WORDPRESS_PORT}/g" /etc/nginx/nginx.conf

echo "Testing nginx configuration:"
nginx -t

echo "Starting nginx..."
exec nginx -g "daemon off;"
