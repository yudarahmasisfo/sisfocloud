# Base image
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori sementara yang bisa ditulis
RUN mkdir -p /tmp/nginx/logs /tmp/nginx/client-body

# Salin file website
COPY . /app

# Konfigurasi NGINX — DIPERBAIKI: log di tempat benar & aman
RUN echo " \
# Error log harus di root context, tapi ke /tmp  
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
    server { \
        listen 7860; \
        root /app; \
        index index.html; \
\
        # access_log harus di dalam blok server
        access_log /tmp/nginx/logs/access.log; \
\
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
\
        # Temporary files untuk upload
        client_body_temp_path /tmp/nginx/client-body; \
    } \
} \
" > /etc/nginx/nginx.conf

# Expose port
EXPOSE 7860

# Jalankan nginx
CMD ["nginx", "-g", "daemon off;"]
