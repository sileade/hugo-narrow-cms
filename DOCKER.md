# 🐳 Docker Deployment Guide

Complete guide for deploying Hugo Narrow CMS using Docker and Docker Compose.

---

## 🚀 Quick Start (30 seconds)

### Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (usually included with Docker Desktop)

### One-Command Deploy

```bash
# Development mode with live reload
./docker-deploy.sh
# Select option 1

# Production mode
./docker-deploy.sh
# Select option 2
```

---

## 📋 Table of Contents

1. [Installation](#installation)
2. [Development Mode](#development-mode)
3. [Production Mode](#production-mode)
4. [Docker Commands](#docker-commands)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Installation

### Install Docker

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install --cask docker
```

**Windows:**
Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Verify Installation

```bash
docker --version
docker-compose --version
```

---

## 💻 Development Mode

### Features

- ✅ **Live Reload** - Changes reflect immediately
- ✅ **Draft Posts** - View unpublished content
- ✅ **Admin Panel** - Full CMS access
- ✅ **Hot Reload** - No manual refresh needed
- ✅ **Fast Builds** - Incremental compilation

### Start Development Server

**Option 1: Using the script (Recommended)**
```bash
./docker-deploy.sh
# Select option 1
```

**Option 2: Using Docker Compose directly**
```bash
docker-compose --profile dev up -d
```

### Access Your Site

- **Website**: http://localhost:1313
- **Admin Panel**: http://localhost:1313/admin/
- **Proxy (with admin)**: http://localhost:8080

### View Logs

```bash
docker-compose --profile dev logs -f
```

### Stop Development Server

```bash
docker-compose --profile dev down
```

### Making Changes

1. Edit files in your local directory
2. Hugo automatically rebuilds
3. Browser refreshes automatically
4. See changes instantly!

---

## 🏭 Production Mode

### Features

- ✅ **Optimized Build** - Minified assets
- ✅ **Nginx Server** - High performance
- ✅ **Gzip Compression** - Faster loading
- ✅ **Static Caching** - CDN-ready
- ✅ **Security Headers** - Best practices

### Start Production Server

**Option 1: Using the script (Recommended)**
```bash
./docker-deploy.sh
# Select option 2
```

**Option 2: Using Docker Compose directly**
```bash
docker-compose --profile prod up -d --build
```

### Access Your Site

- **Website**: http://localhost
- **Admin Panel**: http://localhost/admin/

### View Logs

```bash
docker-compose --profile prod logs -f
```

### Stop Production Server

```bash
docker-compose --profile prod down
```

---

## 🛠️ Docker Commands

### Basic Commands

```bash
# Start development
docker-compose --profile dev up -d

# Start production
docker-compose --profile prod up -d

# Stop all
docker-compose --profile dev --profile prod down

# View logs
docker-compose logs -f

# Rebuild images
docker-compose build --no-cache

# Remove everything
docker-compose down --rmi all --volumes
```

### Container Management

```bash
# List running containers
docker ps

# Enter container shell
docker exec -it hugo-narrow-dev sh

# View container logs
docker logs hugo-narrow-dev

# Restart container
docker restart hugo-narrow-dev

# Stop container
docker stop hugo-narrow-dev

# Remove container
docker rm hugo-narrow-dev
```

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi hugo-narrow-cms_hugo-dev

# Prune unused images
docker image prune -a
```

---

## ⚙️ Configuration

### Environment Variables

Create `.env` file:

```env
# Hugo settings
HUGO_ENV=production
HUGO_VERSION=0.146.0

# Server settings
DEV_PORT=1313
PROD_PORT=80
ADMIN_PORT=8080

# Site settings
BASE_URL=https://yourdomain.com
```

### Custom Ports

Edit `docker-compose.yml`:

```yaml
services:
  hugo-dev:
    ports:
      - "3000:1313"  # Change 3000 to your preferred port
```

### Volume Mounts

Current configuration:

```yaml
volumes:
  - .:/src              # Mount entire project
  - /src/public         # Exclude public directory
  - /src/resources      # Exclude resources directory
```

### Nginx Configuration

Edit `docker/nginx.conf` for custom settings:

- Cache duration
- Security headers
- Gzip settings
- Redirects

---

## 🐛 Troubleshooting

### Port Already in Use

**Problem**: Port 1313 or 80 is already in use

**Solution**:
```bash
# Find process using port
sudo lsof -i :1313

# Kill process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
```

### Container Won't Start

**Problem**: Container exits immediately

**Solution**:
```bash
# Check logs
docker-compose logs

# Rebuild without cache
docker-compose build --no-cache

# Remove old containers
docker-compose down --volumes
```

### Changes Not Reflecting

**Problem**: File changes don't trigger rebuild

**Solution**:
```bash
# Restart development server
docker-compose --profile dev restart

# Or rebuild
docker-compose --profile dev up -d --build
```

### Permission Issues

**Problem**: Permission denied errors

**Solution**:
```bash
# Linux: Fix permissions
sudo chown -R $USER:$USER .

# Or run with sudo
sudo docker-compose up
```

### Build Fails

**Problem**: Docker build fails

**Solution**:
```bash
# Check Hugo version
docker run --rm klakegg/hugo:0.146.0-ext-alpine version

# Clean build
docker-compose build --no-cache --pull

# Check Dockerfile syntax
docker build -t test .
```

### Admin Panel 404

**Problem**: /admin/ returns 404

**Solution**:
```bash
# Verify files exist
ls -la static/admin/

# Rebuild
docker-compose --profile dev up -d --build

# Check nginx config
docker exec hugo-narrow-prod cat /etc/nginx/conf.d/default.conf
```

---

## 📊 Performance Optimization

### Multi-stage Build

The Dockerfile uses multi-stage builds:

1. **Builder** - Compiles Hugo site
2. **Development** - Hugo server with live reload
3. **Production** - Nginx serving static files

### Caching Strategy

```dockerfile
# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source (changes more often)
COPY . .
```

### Image Size

```bash
# Check image size
docker images hugo-narrow-cms*

# Typical sizes:
# Development: ~100MB
# Production: ~30MB
```

---

## 🔒 Security

### Production Recommendations

1. **Use HTTPS**
   ```yaml
   # Add SSL certificates
   volumes:
     - ./certs:/etc/nginx/certs:ro
   ```

2. **Set Security Headers**
   Already configured in `docker/nginx.conf`

3. **Limit Container Resources**
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```

4. **Run as Non-Root**
   ```dockerfile
   USER nginx
   ```

---

## 🚀 Advanced Usage

### Custom Domain

```yaml
environment:
  - VIRTUAL_HOST=yourdomain.com
  - LETSENCRYPT_HOST=yourdomain.com
  - LETSENCRYPT_EMAIL=you@email.com
```

### Multiple Environments

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### CI/CD Integration

**GitHub Actions:**
```yaml
- name: Build Docker image
  run: docker-compose build

- name: Push to registry
  run: docker-compose push
```

**GitLab CI:**
```yaml
build:
  script:
    - docker-compose build
    - docker-compose push
```

---

## 📦 Deployment to Cloud

### Deploy to AWS ECS

```bash
# Install ECS CLI
pip install ecs-cli

# Configure
ecs-cli configure --cluster hugo-cluster --region us-east-1

# Deploy
ecs-cli compose up
```

### Deploy to Google Cloud Run

```bash
# Build and push
docker build -t gcr.io/PROJECT_ID/hugo-narrow .
docker push gcr.io/PROJECT_ID/hugo-narrow

# Deploy
gcloud run deploy hugo-narrow --image gcr.io/PROJECT_ID/hugo-narrow
```

### Deploy to DigitalOcean

```bash
# Create droplet
doctl compute droplet create hugo-server --image docker-20-04

# SSH and deploy
ssh root@YOUR_DROPLET_IP
git clone YOUR_REPO
cd YOUR_REPO
docker-compose --profile prod up -d
```

---

## 🔄 Backup & Restore

### Backup

```bash
# Backup content
docker run --rm -v $(pwd):/backup ubuntu tar czf /backup/content-backup.tar.gz /src/content

# Backup entire site
tar czf hugo-site-backup.tar.gz .
```

### Restore

```bash
# Restore content
tar xzf content-backup.tar.gz

# Rebuild
docker-compose --profile prod up -d --build
```

---

## 📈 Monitoring

### Health Checks

```yaml
healthcheck:
  test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
  interval: 30s
  timeout: 3s
  retries: 3
```

### Logging

```bash
# View logs
docker-compose logs -f

# Save logs to file
docker-compose logs > logs.txt

# Filter logs
docker-compose logs | grep ERROR
```

### Metrics

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Network usage
docker network inspect hugo-narrow-network
```

---

## 🎯 Best Practices

1. **Use .dockerignore** - Exclude unnecessary files
2. **Multi-stage builds** - Smaller images
3. **Health checks** - Monitor container health
4. **Resource limits** - Prevent resource exhaustion
5. **Security scanning** - Scan images for vulnerabilities
6. **Version pinning** - Pin Hugo version
7. **Logging** - Centralized logging
8. **Backups** - Regular content backups

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Hugo Docker Image](https://hub.docker.com/r/klakegg/hugo)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

## 🆘 Getting Help

- **Docker Issues**: https://github.com/docker/docker/issues
- **Hugo Issues**: https://github.com/gohugoio/hugo/issues
- **Project Issues**: https://github.com/sileade/hugo-narrow-cms/issues

---

**Happy Dockerizing! 🐳**
