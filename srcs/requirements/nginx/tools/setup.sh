#!/bin/sh
set -e

DOMAIN_NAME="${DOMAIN_NAME:-localhost}"
WORDPRESS_HOST="${WORDPRESS_HOST:-wordpress}"
WORDPRESS_PORT="${WORDPRESS_PORT:-9000}"

if [ ! -f "/etc/nginx/ssl/server.crt" ] || [ ! -f "/etc/nginx/ssl/server.key" ]; then
    echo "Generating SSL certificate for domain: $DOMAIN_NAME"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=MA/ST=Morocco/L=Tetouan/O=42/OU=Student/CN=$DOMAIN_NAME" \
        -keyout "/etc/nginx/ssl/server.key" \
        -out "/etc/nginx/ssl/server.crt"
fi

sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf
sed -i "s/WORDPRESS_HOST_PLACEHOLDER/${WORDPRESS_HOST}/g" /etc/nginx/nginx.conf
sed -i "s/WORDPRESS_PORT_PLACEHOLDER/${WORDPRESS_PORT}/g" /etc/nginx/nginx.conf

cat > /usr/share/nginx/html/502.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>WordPress Starting</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <h1>WordPress is starting up...</h1>
    <p>Please wait a moment and refresh the page.</p>
</body>
</html>
EOF

echo "Testing nginx configuration:"
nginx -t

echo "Starting nginx..."
exec nginx -g 'daemon off;'