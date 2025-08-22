# Base image
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori sementara yang bisa ditulis oleh user biasa
RUN mkdir -p /tmp/nginx/logs /tmp/nginx/client-body /tmp/nginx/proxy /tmp/nginx/run

# Salin file website
COPY . /app

# Konfigurasi nginx — gunakan /tmp untuk log dan pid
RUN echo " \
error_log /tmp/nginx/logs/error.log; \
pid /tmp/nginx/run/nginx.pid; \
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
    proxy_temp_path /tmp/nginx/proxy; \
    client_body_temp_path /tmp/nginx/client-body; \
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

# Expose port
EXPOSE 7860

# Jalankan nginx
CMD ["nginx", "-g", "daemon off;"]
