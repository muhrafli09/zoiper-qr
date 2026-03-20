# Zoiper QR Code Generator

Aplikasi web untuk generate QR Code konfigurasi Zoiper SIP client.

## Domain
- **Production**: https://zoiper-qr.oncall.id
- **Development**: http://localhost:8083

## Quick Setup

### 1. Automated Setup
```bash
cd /var/www/zoiper-qr-code
./setup.sh
```

### 2. Manual Setup

#### DNS Setup
Tambahkan DNS record:
- **Type**: A
- **Name**: zoiper-qr
- **Value**: IP server Anda
- **TTL**: 300

#### Deploy Application
```bash
cd /var/www/zoiper-qr-code
./deploy.sh
```

#### SSL Setup (Optional)
```bash
./generate-ssl.sh
```

## SSL Options

### 1. Let's Encrypt HTTP Challenge
- Otomatis dan gratis
- Perlu stop container sementara
- Cocok untuk setup pertama

### 2. Let's Encrypt Cloudflare DNS Challenge
- Tidak perlu stop container
- Perlu API token Cloudflare
- Recommended untuk production

### 3. Self-Signed Certificate
- Untuk testing/development
- Browser akan warning
- Setup cepat

## Container Information
- **Container Name**: zoiper-qr-nginx
- **HTTP Port**: 8083
- **HTTPS Port**: 8443
- **Network**: zoiper-qr-code_zoiper-network

## File Structure
```
/var/www/zoiper-qr-code/
├── index.html              # Main application file
├── css/                    # Stylesheets
├── js/                     # JavaScript files
├── fonts/                  # Font files
├── images/                 # Images and icons
├── vendor/                 # Third-party libraries
├── docker/
│   └── nginx.conf         # Nginx configuration
├── docker-compose.yml     # Docker compose configuration
├── setup.sh              # Complete setup script
├── deploy.sh             # Deployment script
├── generate-ssl.sh       # SSL certificate generation
└── README.md            # This file
```

## Features
- Generate QR Code untuk konfigurasi Zoiper
- Support TCP, UDP, TLS protocols
- Responsive design
- SSL/HTTPS support
- Docker containerized

## Usage
1. Buka https://zoiper-qr.oncall.id
2. Masukkan Username, Password, dan Domain SIP
3. Pilih Protocol (TCP/UDP/TLS)
4. QR Code akan ter-generate otomatis
5. Scan QR Code dengan aplikasi Zoiper

## Maintenance

### Container Management
```bash
# View logs
docker logs zoiper-qr-nginx

# Restart container
docker compose restart

# Stop container
docker compose down

# View container status
docker ps | grep zoiper
```

### SSL Certificate Renewal
```bash
# Auto renewal (add to crontab)
0 2 * * * /usr/bin/certbot renew --quiet && docker compose restart

# Manual renewal
certbot renew
docker compose restart
```

### Update Application
```bash
cd /var/www/zoiper-qr-code
git pull origin main
docker compose restart
```

## Troubleshooting

### Container tidak start
```bash
# Check logs
docker logs zoiper-qr-nginx

# Check nginx config
docker exec zoiper-qr-nginx nginx -t
```

### SSL Issues
```bash
# Check certificate
openssl x509 -in /etc/letsencrypt/live/zoiper-qr.oncall.id/fullchain.pem -text -noout

# Regenerate certificate
./generate-ssl.sh
```

### DNS Issues
```bash
# Test DNS resolution
nslookup zoiper-qr.oncall.id
dig zoiper-qr.oncall.id
```