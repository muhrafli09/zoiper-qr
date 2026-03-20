# Zoiper QR Code Generator

Aplikasi web untuk generate QR Code konfigurasi Zoiper SIP client.

## Live Demo
- **Production**: https://zoiper-qr.oncall.id

## Setup

### Requirements
- Docker
- Docker Compose

### Deploy
```bash
git clone https://github.com/muhrafli09/zoiper-qr.git
cd zoiper-qr
docker-compose up -d
```

Aplikasi akan berjalan di `http://localhost:8083`

## File Structure
```
zoiper-qr/
├── index.html              # Main application
├── css/                    # Stylesheets
├── js/                     # JavaScript files
├── fonts/                  # Font files
├── images/                 # Images and icons
├── vendor/                 # Third-party libraries
├── docker/
│   └── nginx.conf         # Nginx configuration
└── docker-compose.yml     # Docker compose configuration
```

## Features
- Generate QR Code untuk konfigurasi Zoiper
- Support TCP, UDP, TLS protocols
- Responsive design
- Docker containerized

## Usage
1. Buka https://zoiper-qr.oncall.id
2. Masukkan Username, Password, dan Domain SIP
3. Pilih Protocol (TCP/UDP/TLS)
4. QR Code akan ter-generate otomatis
5. Scan QR Code dengan aplikasi Zoiper

## Management
```bash
# View logs
docker logs zoiper-qr-nginx

# Restart
docker-compose restart

# Stop
docker-compose down
```
