#!/bin/bash

DOMAIN="zoiper-qr.oncall.id"
CONTAINER_NAME="zoiper-qr-nginx"

echo "🔐 Generating SSL Certificate for $DOMAIN"
echo ""
echo "Pilihan:"
echo "1. Menggunakan Cloudflare DNS Challenge (Recommended)"
echo "2. Menggunakan HTTP Challenge (perlu stop container sementara)"
echo "3. Generate Self-Signed Certificate (untuk testing)"
echo ""
read -p "Pilih opsi (1/2/3): " choice

case $choice in
  1)
    echo "📝 Menggunakan Cloudflare DNS Challenge"
    echo ""
    echo "Pastikan Anda sudah install certbot-dns-cloudflare:"
    echo "  apt-get install python3-certbot-dns-cloudflare"
    echo ""
    echo "Buat file /root/.secrets/cloudflare.ini dengan isi:"
    echo "  dns_cloudflare_api_token = YOUR_CLOUDFLARE_API_TOKEN"
    echo ""
    echo "Kemudian jalankan:"
    echo "  certbot certonly --dns-cloudflare \\"
    echo "    --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \\"
    echo "    -d $DOMAIN \\"
    echo "    --non-interactive --agree-tos --email admin@oncall.id"
    ;;
    
  2)
    echo "🛑 Stopping container temporarily..."
    docker stop $CONTAINER_NAME
    
    echo "📝 Generating certificate..."
    certbot certonly --standalone \
      -d $DOMAIN \
      --non-interactive --agree-tos --email admin@oncall.id
    
    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
      echo "✅ Certificate generated successfully!"
      echo "📝 Updating nginx config to use SSL..."
      
      # Update nginx config to use SSL
      cat > docker/nginx.conf << 'EOF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name zoiper-qr.oncall.id localhost;
    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl;
    http2 on;
    server_name zoiper-qr.oncall.id localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/zoiper-qr.oncall.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/zoiper-qr.oncall.id/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
EOF
      
      echo "🚀 Starting container with SSL..."
      docker compose up -d
      
      echo "✅ Done! Certificate installed and container restarted"
      echo "🌐 Access: https://$DOMAIN"
    else
      echo "❌ Certificate generation failed"
      echo "🚀 Starting container without SSL..."
      docker start $CONTAINER_NAME
    fi
    ;;
    
  3)
    echo "🔧 Generating Self-Signed Certificate..."
    
    mkdir -p /etc/letsencrypt/live/$DOMAIN
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/letsencrypt/live/$DOMAIN/privkey.pem \
      -out /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
      -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Oncall/CN=$DOMAIN"
    
    echo "✅ Self-signed certificate generated"
    echo "📝 Updating nginx config to use SSL..."
    
    # Update nginx config to use SSL
    cat > docker/nginx.conf << 'EOF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name zoiper-qr.oncall.id localhost;
    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl;
    http2 on;
    server_name zoiper-qr.oncall.id localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/zoiper-qr.oncall.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/zoiper-qr.oncall.id/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
EOF
    
    echo "🚀 Restarting container with SSL..."
    docker compose up -d
    
    echo "✅ Done! Self-signed certificate installed"
    echo "⚠️  Browser akan tetap warning karena self-signed"
    echo "🌐 Access: https://$DOMAIN"
    ;;
    
  *)
    echo "❌ Invalid option"
    exit 1
    ;;
esac