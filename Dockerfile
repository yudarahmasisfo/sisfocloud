# Base image
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori yang aman untuk nginx
RUN mkdir -p /tmp/nginx/logs /tmp/nginx/client-body

# Salin file HTML kamu
COPY . /app

# Konfigurasi nginx penuh (tanpa ketergantungan /var)
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
    types_hash_max_size 2048; \
\
    server { \
        listen 7860; \
        root /app; \
        index index.html; \
        \
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
        \
        # Gunakan /tmp untuk temporary files \
        client_body_temp_path /tmp/nginx/client-body; \
        client_max_body_size 10M; \
    } \
}" > /etc/nginx/nginx.conf

# Expose port
EXPOSE 7860

# Jalankan nginx
CMD ["nginx", "-g", "daemon off;"]
