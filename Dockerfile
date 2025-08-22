# Base image
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori sementara di /tmp — lengkap untuk semua fitur nginx
RUN mkdir -p \
    /tmp/nginx/logs \
    /tmp/nginx/client-body \
    /tmp/nginx/proxy \
    /tmp/nginx/fastcgi \
    /tmp/nginx/scgi \
    /tmp/nginx/uwsgi

# Salin file website kamu
COPY . /app

# Konfigurasi nginx — semua path diarahkan ke /tmp
RUN echo " \
# Log ke /tmp, bukan /var/log
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
    # Semua temporary paths diarahkan ke /tmp
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

# Expose port
EXPOSE 7860

# Jalankan nginx
CMD ["nginx", "-g", "daemon off;"]
