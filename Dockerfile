# Base image
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Salin file website
COPY . /app

# Konfigurasi nginx — semua log & temp ke /tmp
RUN echo " \
error_log /tmp/nginx/logs/error.log; \
\
events { \
    worker_connections 1024; \
} \
\
http { \
    include /etc/nginx/mime.types; \
    default_type application/octet-stream; \
    sendfile on; \
    keepalive_timeout 65; \
\
    # Semua temp path ke /tmp
    client_body_temp_path /tmp/nginx/client-body; \
    proxy_temp_path      /tmp/nginx/proxy; \
    fastcgi_temp_path    /tmp/nginx/fastcgi; \
    scgi_temp_path       /tmp/nginx/scgi; \
    uwsgi_temp_path      /tmp/nginx/uwsgi; \
\
    server { \
        listen 7860; \
        root /app; \
        index index.html; \
\
        access_log /tmp/nginx/logs/access.log; \
\
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
    } \
} \
" > /etc/nginx/nginx.conf

# Buat script startup untuk buat folder & set permission
RUN echo '#!/bin/bash \n\
mkdir -p /tmp/nginx/logs /tmp/nginx/client-body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/scgi /tmp/nginx/uwsgi \n\
chmod -R 777 /tmp/nginx \n\
exec nginx -g "daemon off;" \n\
' > /startup.sh && chmod +x /startup.sh

# Expose port
EXPOSE 7860

# Jalankan script startup
CMD ["/startup.sh"]
