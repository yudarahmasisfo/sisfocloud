# Gunakan Ubuntu
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Update & install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori yang bisa ditulis oleh user biasa
RUN mkdir -p /tmp/nginx/logs /tmp/nginx/client-body

# Salin file website
COPY . /app/

# Setup konfigurasi nginx
RUN echo "error_log /tmp/nginx/logs/error.log; \
access_log /tmp/nginx/logs/access.log; \
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
    server { \
        listen 7860; \
        location / { \
            root /app; \
            index index.html; \
            try_files \$uri \$uri/ =404; \
        } \
        # Temporary files \
        client_body_temp_path /tmp/nginx/client-body; \
    } \
}" > /etc/nginx/nginx.conf

# Ekspor port
EXPOSE 7860

# Jalankan nginx sebagai user biasa
CMD ["nginx", "-g", "daemon off;"]
