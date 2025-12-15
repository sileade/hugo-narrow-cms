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

### Deploy to VPS (Detailed Guide)

Подробное пошаговое руководство по развертыванию на VPS (DigitalOcean, Linode, Vultr, Hetzner и т.д.)

#### Шаг 1: Подготовка VPS

**1.1. Создайте VPS**

Выберите провайдера:
- [DigitalOcean](https://www.digitalocean.com/) - от $6/месяц
- [Linode](https://www.linode.com/) - от $5/месяц
- [Vultr](https://www.vultr.com/) - от $6/месяц
- [Hetzner](https://www.hetzner.com/) - от €4/месяц

Минимальные требования:
- **CPU**: 1 core
- **RAM**: 1GB
- **Disk**: 25GB SSD
- **OS**: Ubuntu 22.04 LTS (рекомендуется)

**1.2. Подключитесь к серверу**

```bash
# Получите IP адрес вашего VPS
ssh root@YOUR_SERVER_IP

# При первом подключении подтвердите fingerprint
# Введите пароль (отправлен на email)
```

**1.3. Обновите систему**

```bash
# Обновить список пакетов
apt update

# Обновить установленные пакеты
apt upgrade -y

# Установить необходимые утилиты
apt install -y curl git wget nano ufw
```

**1.4. Создайте пользователя (опционально, но рекомендуется)**

```bash
# Создать пользователя
adduser hugo

# Добавить в группу sudo
usermod -aG sudo hugo

# Переключиться на нового пользователя
su - hugo
```

---

#### Шаг 2: Установка Docker

**2.1. Установите Docker**

```bash
# Скачать скрипт установки
curl -fsSL https://get.docker.com -o get-docker.sh

# Запустить установку
sudo sh get-docker.sh

# Добавить пользователя в группу docker
sudo usermod -aG docker $USER

# Применить изменения (или перелогиниться)
newgrp docker
```

**2.2. Проверьте установку**

```bash
# Проверить версию Docker
docker --version
# Ожидаемый вывод: Docker version 24.x.x

# Проверить Docker Compose
docker compose version
# Ожидаемый вывод: Docker Compose version v2.x.x

# Тестовый запуск
docker run hello-world
```

**2.3. Настройте автозапуск Docker**

```bash
# Включить автозапуск Docker при загрузке системы
sudo systemctl enable docker
sudo systemctl start docker

# Проверить статус
sudo systemctl status docker
```

---

#### Шаг 3: Клонирование репозитория

**3.1. Клонируйте проект**

```bash
# Перейти в домашнюю директорию
cd ~

# Клонировать репозиторий
git clone https://github.com/sileade/hugo-narrow-cms.git

# Перейти в директорию проекта
cd hugo-narrow-cms

# Проверить содержимое
ls -la
```

**3.2. Настройте конфигурацию (опционально)**

```bash
# Отредактировать hugo.yaml
nano hugo.yaml

# Измените baseURL на ваш домен или IP
# baseURL: https://your-domain.com/
# или
# baseURL: http://YOUR_SERVER_IP/

# Сохранить: Ctrl+O, Enter
# Выйти: Ctrl+X
```

---

#### Шаг 4: Развертывание

**4.1. Запустите production режим**

```bash
# Сделать скрипт исполняемым
chmod +x docker-deploy.sh

# Запустить интерактивный скрипт
./docker-deploy.sh
# Выберите опцию 2 (Production)

# ИЛИ напрямую через Docker Compose
docker compose --profile prod up -d --build

# ИЛИ через Make
make prod
```

**4.2. Проверьте статус контейнеров**

```bash
# Список запущенных контейнеров
docker ps

# Должен быть запущен hugo-narrow-prod
# CONTAINER ID   IMAGE                    STATUS
# abc123def456   hugo-narrow-cms_hugo-prod   Up 2 minutes

# Просмотр логов
docker compose --profile prod logs -f

# Выход из логов: Ctrl+C
```

**4.3. Проверьте доступность сайта**

```bash
# Проверить локально на сервере
curl http://localhost

# Должен вернуть HTML код главной страницы
```

---

#### Шаг 5: Настройка Firewall

**5.1. Настройте UFW (Uncomplicated Firewall)**

```bash
# Разрешить SSH (ВАЖНО! Сделайте это первым)
sudo ufw allow 22/tcp
# или если используете нестандартный порт:
# sudo ufw allow YOUR_SSH_PORT/tcp

# Разрешить HTTP
sudo ufw allow 80/tcp

# Разрешить HTTPS (для будущего использования)
sudo ufw allow 443/tcp

# Включить firewall
sudo ufw enable

# Проверить статус
sudo ufw status
```

**5.2. Проверьте доступность извне**

Откройте браузер и перейдите по адресу:
```
http://YOUR_SERVER_IP
```

Вы должны увидеть ваш сайт! 🎉

---

#### Шаг 6: Настройка домена (опционально)

**6.1. Настройте DNS записи**

В панели управления вашего регистратора доменов добавьте:

```
Тип: A
Имя: @
Значение: YOUR_SERVER_IP
TTL: 3600

Тип: A
Имя: www
Значение: YOUR_SERVER_IP
TTL: 3600
```

**6.2. Дождитесь распространения DNS**

```bash
# Проверить DNS (может занять до 24 часов)
dig your-domain.com
nslookup your-domain.com

# Или используйте онлайн инструмент:
# https://dnschecker.org/
```

**6.3. Обновите baseURL в конфигурации**

```bash
# Остановить контейнеры
docker compose --profile prod down

# Отредактировать hugo.yaml
nano hugo.yaml
# Изменить: baseURL: https://your-domain.com/

# Пересобрать и запустить
docker compose --profile prod up -d --build
```

---

#### Шаг 7: Установка SSL сертификата (Let's Encrypt)

**7.1. Установите Certbot**

```bash
# Установить Certbot
sudo apt install -y certbot python3-certbot-nginx
```

**7.2. Создайте Nginx конфигурацию для SSL**

```bash
# Создать директорию для конфигурации
mkdir -p ~/hugo-narrow-cms/docker/ssl

# Создать nginx конфигурацию с SSL
cat > ~/hugo-narrow-cms/docker/nginx-ssl.conf << 'EOF'
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Main location
    location / {
        try_files $uri $uri/ /index.html =404;
    }
    
    # Admin panel
    location /admin {
        try_files $uri $uri/ /admin/index.html;
    }
}
EOF

# Замените your-domain.com на ваш домен
sed -i 's/your-domain.com/YOUR_ACTUAL_DOMAIN/g' ~/hugo-narrow-cms/docker/nginx-ssl.conf
```

**7.3. Получите SSL сертификат**

```bash
# Остановить контейнеры (освободить порт 80)
docker compose --profile prod down

# Получить сертификат
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Следуйте инструкциям:
# - Введите email
# - Согласитесь с условиями
# - Выберите опции
```

**7.4. Обновите docker-compose.yml для SSL**

```bash
# Создать docker-compose.prod.yml с SSL
cat > ~/hugo-narrow-cms/docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  hugo-prod:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: hugo-narrow-prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - ./docker/nginx-ssl.conf:/etc/nginx/conf.d/default.conf:ro
    restart: unless-stopped
EOF

# Запустить с SSL конфигурацией
docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile prod up -d --build
```

**7.5. Настройте автообновление сертификата**

```bash
# Создать скрипт обновления
sudo cat > /usr/local/bin/renew-cert.sh << 'EOF'
#!/bin/bash
docker compose -f /home/hugo/hugo-narrow-cms/docker-compose.yml --profile prod down
certbot renew --quiet
docker compose -f /home/hugo/hugo-narrow-cms/docker-compose.yml --profile prod up -d
EOF

# Сделать исполняемым
sudo chmod +x /usr/local/bin/renew-cert.sh

# Добавить в cron (запуск каждый день в 3:00)
sudo crontab -e
# Добавить строку:
0 3 * * * /usr/local/bin/renew-cert.sh
```

---

#### Шаг 8: Автоматическое обновление

**8.1. Создайте скрипт обновления**

```bash
# Создать скрипт
cat > ~/hugo-narrow-cms/update.sh << 'EOF'
#!/bin/bash
set -e

echo "🔄 Updating Hugo Narrow CMS..."

# Pull latest changes
cd ~/hugo-narrow-cms
git pull origin main

# Rebuild and restart
docker compose --profile prod down
docker compose --profile prod up -d --build

echo "✅ Update complete!"
EOF

# Сделать исполняемым
chmod +x ~/hugo-narrow-cms/update.sh
```

**8.2. Настройте webhook (опционально)**

Для автоматического обновления при push в GitHub:

```bash
# Установить webhook сервер
sudo apt install -y webhook

# Создать конфигурацию webhook
mkdir -p ~/webhooks
cat > ~/webhooks/hooks.json << 'EOF'
[
  {
    "id": "hugo-update",
    "execute-command": "/home/hugo/hugo-narrow-cms/update.sh",
    "command-working-directory": "/home/hugo/hugo-narrow-cms",
    "response-message": "Updating site..."
  }
]
EOF

# Запустить webhook сервер
webhook -hooks ~/webhooks/hooks.json -port 9000 &

# Добавить в GitHub:
# Settings → Webhooks → Add webhook
# Payload URL: http://YOUR_SERVER_IP:9000/hooks/hugo-update
# Content type: application/json
```

---

#### Шаг 9: Мониторинг и обслуживание

**9.1. Просмотр логов**

```bash
# Логи контейнера
docker compose --profile prod logs -f

# Логи Nginx (внутри контейнера)
docker exec hugo-narrow-prod cat /var/log/nginx/access.log
docker exec hugo-narrow-prod cat /var/log/nginx/error.log

# Системные логи
sudo journalctl -u docker -f
```

**9.2. Мониторинг ресурсов**

```bash
# Использование ресурсов контейнерами
docker stats

# Использование диска
df -h

# Использование памяти
free -h

# Загрузка CPU
top
# или
htop  # (установить: sudo apt install htop)
```

**9.3. Резервное копирование**

```bash
# Создать backup скрипт
cat > ~/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/hugo/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Создать директорию для backup
mkdir -p $BACKUP_DIR

# Backup контента
tar czf $BACKUP_DIR/content_$DATE.tar.gz -C ~/hugo-narrow-cms content/

# Backup конфигурации
tar czf $BACKUP_DIR/config_$DATE.tar.gz -C ~/hugo-narrow-cms hugo.yaml static/admin/

# Удалить старые backup (старше 30 дней)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "✅ Backup created: $DATE"
EOF

# Сделать исполняемым
chmod +x ~/backup.sh

# Добавить в cron (каждый день в 2:00)
crontab -e
# Добавить:
0 2 * * * /home/hugo/backup.sh
```

**9.4. Очистка Docker**

```bash
# Удалить неиспользуемые образы
docker image prune -a

# Удалить неиспользуемые контейнеры
docker container prune

# Удалить неиспользуемые volumes
docker volume prune

# Полная очистка
docker system prune -a --volumes
```

---

#### Шаг 10: Полезные команды

**Управление контейнерами:**

```bash
# Перезапустить
docker compose --profile prod restart

# Остановить
docker compose --profile prod down

# Запустить
docker compose --profile prod up -d

# Пересобрать
docker compose --profile prod up -d --build

# Войти в контейнер
docker exec -it hugo-narrow-prod sh

# Проверить статус
docker compose --profile prod ps
```

**Обновление контента:**

```bash
# Через Git
cd ~/hugo-narrow-cms
git pull
docker compose --profile prod restart

# Через админ-панель
# Откройте: https://your-domain.com/admin/
# Войдите через GitHub
# Редактируйте контент
```

**Проверка производительности:**

```bash
# Время отклика
curl -w "@curl-format.txt" -o /dev/null -s https://your-domain.com

# Создать curl-format.txt:
cat > curl-format.txt << 'EOF'
    time_namelookup:  %{time_namelookup}s\n
       time_connect:  %{time_connect}s\n
    time_appconnect:  %{time_appconnect}s\n
   time_pretransfer:  %{time_pretransfer}s\n
      time_redirect:  %{time_redirect}s\n
 time_starttransfer:  %{time_starttransfer}s\n
                    ----------\n
         time_total:  %{time_total}s\n
EOF
```

---

#### Troubleshooting VPS

**Проблема: Сайт недоступен**

```bash
# 1. Проверить контейнер
docker ps
docker compose --profile prod logs

# 2. Проверить firewall
sudo ufw status

# 3. Проверить Nginx внутри контейнера
docker exec hugo-narrow-prod nginx -t

# 4. Проверить порты
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

**Проблема: Нехватка памяти**

```bash
# Проверить использование
free -h
docker stats

# Добавить swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Сделать постоянным
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**Проблема: Нехватка места**

```bash
# Проверить использование
df -h
du -sh ~/hugo-narrow-cms/*

# Очистить Docker
docker system prune -a --volumes

# Очистить логи
sudo journalctl --vacuum-time=7d
```

---

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
