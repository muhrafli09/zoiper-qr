#!/bin/bash

DOMAIN="zoiper-qr.oncall.id"
PROJECT_DIR="/var/www/zoiper-qr-code"

echo "=== Zoiper QR Code Deployment Script ==="
echo "Domain: $DOMAIN"
echo "Project Directory: $PROJECT_DIR"
echo ""

# Set proper permissions
echo "Setting proper permissions..."
chown -R www-data:www-data $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# Check if SSL certificate exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "SSL certificate found for $DOMAIN"
    SSL_AVAILABLE=true
else
    echo "SSL certificate not found for $DOMAIN"
    SSL_AVAILABLE=false
fi

# Start container
echo "Starting Docker container..."
cd $PROJECT_DIR
docker compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Deployment Successful ==="
    echo "Container: zoiper-qr-nginx"
    echo "HTTP Port: 8083"
    echo "HTTPS Port: 8443"
    
    if [ "$SSL_AVAILABLE" = true ]; then
        echo "Access URL: https://$DOMAIN"
        echo "HTTP URL: http://$DOMAIN (redirects to HTTPS)"
    else
        echo "Access URL: http://$DOMAIN:8083"
        echo ""
        echo "To enable SSL, run: ./generate-ssl.sh"
    fi
    
    echo ""
    echo "Container Status:"
    docker ps | grep zoiper-qr-nginx
else
    echo "Deployment failed!"
    exit 1
fi