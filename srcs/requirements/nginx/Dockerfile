FROM debian:bookworm-slim

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /run/nginx /var/cache/nginx /var/www/html /usr/share/nginx/html

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup.sh"]