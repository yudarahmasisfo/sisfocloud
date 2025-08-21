# Base: Ubuntu + nginx
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Salin semua file ke web root
COPY . /var/www/html/

# Konfigurasi nginx listen di port 7860
EXPOSE 7860

RUN echo "server { \
    listen 7860; \
    server_name localhost; \
    location / { \
        root /var/www/html; \
        index index.html; \
        try_files \$uri \$uri/ =404; \
    } \
}" > /etc/nginx/sites-available/default

# Jalankan nginx
CMD ["nginx", "-g", "daemon off;"]
