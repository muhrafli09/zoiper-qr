#!/bin/bash

DOMAIN="zoiper-qr.oncall.id"
PROJECT_DIR="/var/www/zoiper-qr-code"

echo "=== Zoiper QR Code Setup Script ==="
echo "Domain: $DOMAIN"
echo ""

echo "📋 Setup Steps:"
echo "1. Setup DNS Record"
echo "2. Generate SSL Certificate"
echo "3. Deploy Application"
echo ""

echo "🌐 DNS Setup Instructions:"
echo "Add the following DNS record to your domain:"
echo "Type: A"
echo "Name: zoiper-qr"
echo "Value: $(curl -s ifconfig.me)"
echo "TTL: 300"
echo ""
echo "Or if using Cloudflare:"
echo "Type: A"
echo "Name: zoiper-qr"
echo "Value: $(curl -s ifconfig.me)"
echo "Proxy: Orange Cloud (Proxied)"
echo ""

read -p "Have you added the DNS record? (y/n): " dns_ready

if [ "$dns_ready" != "y" ]; then
    echo "❌ Please add the DNS record first, then run this script again"
    exit 1
fi

echo ""
echo "🔍 Testing DNS resolution..."
if nslookup $DOMAIN > /dev/null 2>&1; then
    echo "✅ DNS resolution successful"
else
    echo "⚠️  DNS not yet propagated, but continuing..."
fi

echo ""
echo "🔐 SSL Certificate Setup"
echo "Choose SSL method:"
echo "1. Let's Encrypt with HTTP Challenge (Recommended)"
echo "2. Let's Encrypt with Cloudflare DNS Challenge"
echo "3. Self-Signed Certificate (Testing only)"
echo "4. Skip SSL (HTTP only)"
echo ""
read -p "Choose option (1-4): " ssl_choice

case $ssl_choice in
    1|2|3)
        echo "🚀 Running SSL generation..."
        cd $PROJECT_DIR
        echo "$ssl_choice" | ./generate-ssl.sh
        ;;
    4)
        echo "⚠️  Skipping SSL setup - using HTTP only"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "=== Setup Complete ==="
echo "🌐 Domain: $DOMAIN"
echo "📁 Project: $PROJECT_DIR"
echo "🐳 Container: zoiper-qr-nginx"
echo ""

if [ "$ssl_choice" = "4" ]; then
    echo "🔗 Access URL: http://$DOMAIN:8083"
else
    echo "🔗 Access URL: https://$DOMAIN"
    echo "🔗 HTTP URL: http://$DOMAIN (redirects to HTTPS)"
fi

echo ""
echo "📊 Container Status:"
docker ps | grep zoiper-qr-nginx

echo ""
echo "🔧 Useful Commands:"
echo "  View logs: docker logs zoiper-qr-nginx"
echo "  Restart: docker compose restart"
echo "  Stop: docker compose down"
echo "  SSL setup: ./generate-ssl.sh"