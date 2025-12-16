# 🚀 Self-Hosted Deployment Guide

Complete guide for deploying Hugo Narrow CMS on your own server with Docker Compose, Traefik reverse proxy, and automatic SSL certificates.

---

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Prerequisites](#-prerequisites)
3. [Installation](#-installation)
4. [Traefik Configuration](#-traefik-configuration)
5. [SSL Certificate Setup](#-ssl-certificate-setup)
6. [DNS Configuration](#-dns-configuration)
7. [Deployment](#-deployment)
8. [Services Overview](#-services-overview)
9. [Management](#-management)
10. [Troubleshooting](#-troubleshooting)

---

## ⚡ Quick Start

**Deploy in 3 commands:**

```bash
git clone https://github.com/sileade/hugo-narrow-cms.git
cd hugo-narrow-cms
./quick-start.sh
```

Choose **option 2** for production deployment with SSL.

---

## 📦 Prerequisites

### Server Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 1 core | 2+ cores |
| RAM | 1 GB | 2+ GB |
| Storage | 10 GB | 20+ GB |
| OS | Ubuntu 20.04+ | Ubuntu 22.04 LTS |

### Required Software

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose-plugin -y

# Verify installation
docker --version        # Docker version 24.0+
docker compose version  # Docker Compose version v2.0+
```

### Required Ports

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 22 | TCP | SSH | Server access |
| 80 | TCP | HTTP | Traefik (redirects to HTTPS) |
| 443 | TCP | HTTPS | Traefik (main traffic) |

---

## 🔧 Installation

### Step 1: Clone Repository

```bash
cd /opt
sudo git clone https://github.com/sileade/hugo-narrow-cms.git
sudo chown -R $USER:$USER hugo-narrow-cms
cd hugo-narrow-cms
```

### Step 2: Create Environment File

```bash
cp .env.example .env
nano .env
```

**Configure these variables:**

```bash
# ===========================================
# DOMAIN CONFIGURATION (REQUIRED)
# ===========================================
DOMAIN=yourdomain.com
ACME_EMAIL=your-email@example.com

# ===========================================
# ADMIN PANEL CREDENTIALS (REQUIRED)
# ===========================================
ADMIN_USERNAME=admin
ADMIN_PASSWORD=YourStrongPassword123!

# ===========================================
# DATABASE (REQUIRED)
# ===========================================
POSTGRES_USER=umami
POSTGRES_PASSWORD=YourDatabasePassword456!
POSTGRES_DB=umami

# ===========================================
# SECRETS (GENERATE WITH: openssl rand -hex 32)
# ===========================================
ADMIN_SECRET_KEY=your-64-character-secret-key-here
UMAMI_SECRET=your-64-character-umami-secret-here
WEBHOOK_SECRET=your-64-character-webhook-secret-here

# ===========================================
# TRAEFIK DASHBOARD AUTH
# Generate with: htpasswd -nb admin password
# ===========================================
TRAEFIK_AUTH=admin:$apr1$xyz123...

# ===========================================
# GIT CONFIGURATION (OPTIONAL)
# ===========================================
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your-email@example.com
```

### Step 3: Generate Secrets

```bash
# Generate random secrets
echo "ADMIN_SECRET_KEY=$(openssl rand -hex 32)" >> .env
echo "UMAMI_SECRET=$(openssl rand -hex 32)" >> .env
echo "WEBHOOK_SECRET=$(openssl rand -hex 32)" >> .env

# Generate Traefik dashboard password
sudo apt-get install apache2-utils -y
htpasswd -nb admin YourTraefikPassword
# Copy output to TRAEFIK_AUTH in .env
```

---

## 🔀 Traefik Configuration

Traefik is the reverse proxy that handles all incoming traffic, SSL termination, and routing to services.

### Architecture

```
                    ┌─────────────────────────────────────────┐
                    │              INTERNET                    │
                    └─────────────────┬───────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │           TRAEFIK (Port 80/443)         │
                    │                                         │
                    │  • SSL Termination (Let's Encrypt)      │
                    │  • HTTP → HTTPS Redirect                │
                    │  • Load Balancing                       │
                    │  • Security Headers                     │
                    └─────────────────┬───────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
          ▼                           ▼                           ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   Hugo/Nginx    │       │   Flask Admin   │       │   Uptime Kuma   │
│   (Port 80)     │       │   (Port 5000)   │       │   (Port 3001)   │
│                 │       │                 │       │                 │
│ yourdomain.com  │       │ yourdomain.com  │       │ monitor.        │
│                 │       │ /admin/*        │       │ yourdomain.com  │
└─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Traefik Configuration File

**File: `traefik/traefik.yml`**

```yaml
# ===========================================
# TRAEFIK STATIC CONFIGURATION
# ===========================================

# API and Dashboard
api:
  dashboard: true
  insecure: false

# Entry Points (Ports)
entryPoints:
  # HTTP - Port 80 (redirects to HTTPS)
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true

  # HTTPS - Port 443 (main traffic)
  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt
        domains:
          - main: "yourdomain.com"
            sans:
              - "*.yourdomain.com"

# Certificate Resolvers (Let's Encrypt)
certificatesResolvers:
  letsencrypt:
    acme:
      # Email for Let's Encrypt notifications
      email: "your-email@example.com"
      
      # Certificate storage file
      storage: "/letsencrypt/acme.json"
      
      # Use HTTP-01 challenge (port 80)
      httpChallenge:
        entryPoint: web
      
      # For testing, use staging server:
      # caServer: "https://acme-staging-v02.api.letsencrypt.org/directory"
      
      # For production, use:
      # caServer: "https://acme-v02.api.letsencrypt.org/directory"

# Providers (Docker)
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: hugo-network
  
  # File provider for additional configuration
  file:
    directory: "/etc/traefik/dynamic"
    watch: true

# Logging
log:
  level: INFO
  format: common

# Access Logs
accessLog:
  filePath: "/var/log/traefik/access.log"
  format: common
  bufferingSize: 100
```

### Dynamic Configuration

**File: `traefik/dynamic/security.yml`**

```yaml
# ===========================================
# TRAEFIK DYNAMIC CONFIGURATION - SECURITY
# ===========================================

http:
  middlewares:
    # Security Headers
    security-headers:
      headers:
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
        customFrameOptionsValue: "SAMEORIGIN"
        customResponseHeaders:
          X-Robots-Tag: "noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
          server: ""
          X-Powered-By: ""

    # Rate Limiting
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
        period: 1m

    # Basic Auth for Traefik Dashboard
    traefik-auth:
      basicAuth:
        users:
          - "admin:$apr1$xyz123..."  # Generated with htpasswd

    # Compress responses
    compress:
      compress:
        excludedContentTypes:
          - text/event-stream

    # Redirect www to non-www
    www-redirect:
      redirectRegex:
        regex: "^https://www\\.(.*)"
        replacement: "https://${1}"
        permanent: true
```

### Docker Compose Traefik Service

**In `docker-compose.prod.yml`:**

```yaml
services:
  traefik:
    image: traefik:v3.0
    container_name: hugo-traefik
    restart: unless-stopped
    
    # Security: run as non-root
    security_opt:
      - no-new-privileges:true
    
    ports:
      - "80:80"
      - "443:443"
    
    volumes:
      # Docker socket (read-only)
      - /var/run/docker.sock:/var/run/docker.sock:ro
      
      # Traefik configuration
      - ./traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./traefik/dynamic:/etc/traefik/dynamic:ro
      
      # SSL certificates storage
      - ./traefik/letsencrypt:/letsencrypt
      
      # Logs
      - ./traefik/logs:/var/log/traefik
    
    environment:
      - TZ=UTC
    
    networks:
      - hugo-network
    
    labels:
      # Enable Traefik for this container
      - "traefik.enable=true"
      
      # Traefik Dashboard
      - "traefik.http.routers.traefik.rule=Host(`traefik.${DOMAIN}`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=traefik-auth@file"
    
    healthcheck:
      test: ["CMD", "traefik", "healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## 🔒 SSL Certificate Setup

### How Let's Encrypt Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    SSL CERTIFICATE FLOW                          │
└─────────────────────────────────────────────────────────────────┘

1. REQUEST
   ┌─────────┐         ┌─────────┐         ┌─────────────────┐
   │ Traefik │ ──────► │ Let's   │ ──────► │ Your Server     │
   │         │ Request │ Encrypt │ Verify  │ Port 80         │
   │         │ Cert    │         │ Domain  │ /.well-known/   │
   └─────────┘         └─────────┘         └─────────────────┘

2. VALIDATION (HTTP-01 Challenge)
   Let's Encrypt places a token at:
   http://yourdomain.com/.well-known/acme-challenge/TOKEN
   
   Traefik responds with the correct answer.

3. ISSUANCE
   ┌─────────────────┐         ┌─────────┐
   │ Let's Encrypt   │ ──────► │ Traefik │
   │ Issues          │ Cert    │ Stores  │
   │ Certificate     │         │ in      │
   │                 │         │ acme.json│
   └─────────────────┘         └─────────┘

4. AUTO-RENEWAL
   Traefik automatically renews certificates 30 days before expiry.
```

### SSL Configuration Steps

#### Step 1: Create Certificate Storage

```bash
# Create directory for certificates
mkdir -p traefik/letsencrypt

# Create empty acme.json with correct permissions
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
```

#### Step 2: Configure ACME in traefik.yml

```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      # Your email (required for Let's Encrypt notifications)
      email: "your-email@example.com"
      
      # Storage file for certificates
      storage: "/letsencrypt/acme.json"
      
      # HTTP-01 challenge (recommended)
      httpChallenge:
        entryPoint: web
```

#### Step 3: Apply SSL to Services

Each service needs these labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.yourdomain.com`)"
  - "traefik.http.routers.myservice.entrypoints=websecure"
  - "traefik.http.routers.myservice.tls.certresolver=letsencrypt"
```

### SSL for All Services

**Hugo Site (main domain):**
```yaml
hugo:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.hugo.rule=Host(`${DOMAIN}`)"
    - "traefik.http.routers.hugo.entrypoints=websecure"
    - "traefik.http.routers.hugo.tls.certresolver=letsencrypt"
    - "traefik.http.services.hugo.loadbalancer.server.port=80"
```

**Admin Panel (path-based routing):**
```yaml
admin:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.admin.rule=Host(`${DOMAIN}`) && PathPrefix(`/admin`)"
    - "traefik.http.routers.admin.entrypoints=websecure"
    - "traefik.http.routers.admin.tls.certresolver=letsencrypt"
    - "traefik.http.services.admin.loadbalancer.server.port=5000"
```

**Monitoring (subdomain):**
```yaml
uptime-kuma:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.monitor.rule=Host(`monitor.${DOMAIN}`)"
    - "traefik.http.routers.monitor.entrypoints=websecure"
    - "traefik.http.routers.monitor.tls.certresolver=letsencrypt"
    - "traefik.http.services.monitor.loadbalancer.server.port=3001"
```

### Verify SSL Certificates

```bash
# Check certificate status
docker compose -f docker-compose.prod.yml logs traefik | grep -i "certificate"

# View acme.json (contains certificates)
sudo cat traefik/letsencrypt/acme.json | jq '.letsencrypt.Certificates'

# Test SSL with curl
curl -vI https://yourdomain.com 2>&1 | grep -E "(SSL|certificate|subject)"

# Online SSL test
# https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com
```

### Troubleshooting SSL

**Problem: Certificate not issued**

```bash
# Check Traefik logs
docker compose -f docker-compose.prod.yml logs traefik | grep -i "acme"

# Common issues:
# 1. DNS not propagated - wait 5-10 minutes
# 2. Port 80 blocked - check firewall
# 3. Rate limit exceeded - wait 1 hour
```

**Problem: Certificate expired**

```bash
# Force renewal
docker compose -f docker-compose.prod.yml restart traefik

# Delete old certificates (will regenerate)
rm traefik/letsencrypt/acme.json
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
docker compose -f docker-compose.prod.yml restart traefik
```

**Use Staging Server for Testing:**

```yaml
# In traefik.yml, add:
certificatesResolvers:
  letsencrypt:
    acme:
      caServer: "https://acme-staging-v02.api.letsencrypt.org/directory"
```

---

## 🌐 DNS Configuration

### Required DNS Records

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | YOUR_SERVER_IP | 300 |
| A | www | YOUR_SERVER_IP | 300 |
| A | monitor | YOUR_SERVER_IP | 300 |
| A | analytics | YOUR_SERVER_IP | 300 |
| A | traefik | YOUR_SERVER_IP | 300 |

### Configure DNS at Your Registrar

**Example for Cloudflare:**

1. Login to Cloudflare dashboard
2. Select your domain
3. Go to **DNS** → **Records**
4. Add records:

```
Type: A
Name: @
IPv4 address: 123.45.67.89
Proxy status: DNS only (grey cloud) ← Important for Let's Encrypt!
TTL: Auto

Type: A
Name: monitor
IPv4 address: 123.45.67.89
Proxy status: DNS only
TTL: Auto
```

**Important:** Disable Cloudflare proxy (orange cloud) initially for Let's Encrypt to work. You can enable it after certificates are issued.

### Verify DNS Propagation

```bash
# Check DNS records
dig yourdomain.com +short
dig monitor.yourdomain.com +short

# Or use online tool
# https://dnschecker.org/
```

---

## 🚀 Deployment

### Option 1: Quick Start Script

```bash
./quick-start.sh
```

Select **option 2** for production.

### Option 2: Full Production Script

```bash
./deploy-prod.sh
```

### Option 3: Manual Deployment

```bash
# 1. Create directories
mkdir -p traefik/letsencrypt traefik/logs backups postgres

# 2. Set permissions
chmod 600 traefik/letsencrypt/acme.json

# 3. Build Hugo site
hugo --minify

# 4. Start services
docker compose -f docker-compose.prod.yml up -d

# 5. Check status
docker compose -f docker-compose.prod.yml ps

# 6. View logs
docker compose -f docker-compose.prod.yml logs -f
```

### Deployment Checklist

- [ ] Server meets requirements
- [ ] Docker and Docker Compose installed
- [ ] Repository cloned
- [ ] `.env` file configured
- [ ] DNS records created
- [ ] Firewall ports opened (80, 443)
- [ ] `deploy-prod.sh` executed
- [ ] All services running
- [ ] SSL certificates issued
- [ ] Website accessible via HTTPS

---

## 📊 Services Overview

After deployment, you'll have these services:

| Service | URL | Description |
|---------|-----|-------------|
| **Website** | `https://yourdomain.com` | Main Hugo site |
| **Admin Panel** | `https://yourdomain.com/admin` | Flask admin |
| **Static Admin** | `https://yourdomain.com/admin/` | Decap CMS |
| **Monitoring** | `https://monitor.yourdomain.com` | Uptime Kuma |
| **Analytics** | `https://analytics.yourdomain.com` | Umami |
| **Traefik** | `https://traefik.yourdomain.com` | Dashboard |

---

## 🎛️ Management

### Common Commands

```bash
# View all services
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f

# Restart all services
docker compose -f docker-compose.prod.yml restart

# Stop all services
docker compose -f docker-compose.prod.yml down

# Update and redeploy
git pull && ./deploy-prod.sh
```

### Backup

```bash
# Manual backup
tar -czf backup-$(date +%Y%m%d).tar.gz content/ static/ postgres/

# Backups run automatically daily
ls -lh backups/
```

---

## 🐛 Troubleshooting

### Services Not Starting

```bash
docker compose -f docker-compose.prod.yml logs
```

### SSL Issues

```bash
# Check Traefik logs
docker compose -f docker-compose.prod.yml logs traefik | grep -i acme

# Verify DNS
nslookup yourdomain.com

# Check ports
sudo netstat -tlnp | grep -E "80|443"
```

### Website Not Accessible

```bash
# Check if services are running
docker compose -f docker-compose.prod.yml ps

# Check firewall
sudo ufw status

# Test locally
curl -I http://localhost
```

---

## 📚 Additional Resources

- **Traefik Documentation:** https://doc.traefik.io/traefik/
- **Let's Encrypt:** https://letsencrypt.org/docs/
- **Docker Documentation:** https://docs.docker.com/
- **Hugo Documentation:** https://gohugo.io/documentation/

---

## 🎉 Success!

After completing this guide, you'll have:

- ✅ Hugo site running on your domain
- ✅ Automatic SSL certificates (Let's Encrypt)
- ✅ Admin panel for content management
- ✅ Monitoring dashboard (Uptime Kuma)
- ✅ Privacy-friendly analytics (Umami)
- ✅ Automatic daily backups
- ✅ Auto-deploy with GitHub webhooks

**Happy self-hosting! 🚀**
