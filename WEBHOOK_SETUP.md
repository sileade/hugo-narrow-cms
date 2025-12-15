# 🔗 GitHub Webhook для автоматического деплоя

Полная настройка автоматического развертывания при push в GitHub.

---

## 📋 Содержание

1. [Быстрая настройка](#быстрая-настройка)
2. [Подробная инструкция](#подробная-инструкция)
3. [Конфигурационные файлы](#конфигурационные-файлы)
4. [Настройка GitHub](#настройка-github)
5. [Тестирование](#тестирование)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Быстрая настройка

### На сервере

```bash
# 1. Установить webhook
sudo apt update
sudo apt install -y webhook

# 2. Создать директорию
mkdir -p ~/webhooks

# 3. Создать конфигурацию
cat > ~/webhooks/hooks.json << 'EOF'
[
  {
    "id": "hugo-deploy",
    "execute-command": "/home/hugo/hugo-narrow-cms/deploy.sh",
    "command-working-directory": "/home/hugo/hugo-narrow-cms",
    "response-message": "Deploying...",
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hash-sha256",
            "secret": "YOUR_SECRET_HERE",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
EOF

# 4. Создать скрипт деплоя
cat > ~/hugo-narrow-cms/deploy.sh << 'EOF'
#!/bin/bash
set -e

LOG_FILE="/home/hugo/webhooks/deploy.log"

echo "==================================" >> $LOG_FILE
echo "Deploy started: $(date)" >> $LOG_FILE

cd /home/hugo/hugo-narrow-cms

# Pull latest changes
echo "Pulling latest changes..." >> $LOG_FILE
git pull origin main >> $LOG_FILE 2>&1

# Rebuild and restart
echo "Rebuilding containers..." >> $LOG_FILE
docker compose --profile prod down >> $LOG_FILE 2>&1
docker compose --profile prod up -d --build >> $LOG_FILE 2>&1

echo "Deploy completed: $(date)" >> $LOG_FILE
echo "==================================" >> $LOG_FILE
EOF

chmod +x ~/hugo-narrow-cms/deploy.sh

# 5. Сгенерировать секрет
SECRET=$(openssl rand -hex 32)
echo "Your webhook secret: $SECRET"
echo $SECRET > ~/webhooks/secret.txt

# 6. Обновить конфигурацию с секретом
sed -i "s/YOUR_SECRET_HERE/$SECRET/g" ~/webhooks/hooks.json

# 7. Запустить webhook сервер
webhook -hooks ~/webhooks/hooks.json -port 9000 -verbose &

# 8. Открыть порт в firewall
sudo ufw allow 9000/tcp
```

### В GitHub

1. Откройте: `https://github.com/sileade/hugo-narrow-cms/settings/hooks`
2. Нажмите "Add webhook"
3. Заполните:
   - **Payload URL**: `http://YOUR_SERVER_IP:9000/hooks/hugo-deploy`
   - **Content type**: `application/json`
   - **Secret**: (скопируйте из `~/webhooks/secret.txt`)
   - **Events**: Just the push event
4. Нажмите "Add webhook"

**Готово!** Теперь при каждом push в main будет автоматический деплой.

---

## 📖 Подробная инструкция

### Шаг 1: Установка webhook

**Что такое webhook?**
Webhook - это HTTP endpoint, который GitHub вызывает при определенных событиях (push, pull request и т.д.).

**Установка:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y webhook

# Или скачать бинарник
wget https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz
tar xzf webhook-linux-amd64.tar.gz
sudo mv webhook-linux-amd64/webhook /usr/local/bin/
```

**Проверка:**
```bash
webhook --version
```

---

### Шаг 2: Создание конфигурации

**Создать директорию:**
```bash
mkdir -p ~/webhooks
cd ~/webhooks
```

**Создать hooks.json:**

```json
[
  {
    "id": "hugo-deploy",
    "execute-command": "/home/hugo/hugo-narrow-cms/deploy.sh",
    "command-working-directory": "/home/hugo/hugo-narrow-cms",
    "response-message": "Deployment started successfully",
    "pass-arguments-to-command": [
      {
        "source": "payload",
        "name": "head_commit.id"
      },
      {
        "source": "payload",
        "name": "pusher.name"
      },
      {
        "source": "payload",
        "name": "head_commit.message"
      }
    ],
    "pass-environment-to-command": [
      {
        "source": "payload",
        "envname": "COMMIT_ID",
        "name": "head_commit.id"
      },
      {
        "source": "payload",
        "envname": "PUSHER",
        "name": "pusher.name"
      },
      {
        "source": "payload",
        "envname": "COMMIT_MSG",
        "name": "head_commit.message"
      }
    ],
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hash-sha256",
            "secret": "YOUR_SECRET_HERE",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
```

**Объяснение полей:**

- `id` - уникальный идентификатор webhook
- `execute-command` - путь к скрипту, который будет выполнен
- `command-working-directory` - рабочая директория
- `response-message` - сообщение, возвращаемое GitHub
- `pass-arguments-to-command` - аргументы из payload GitHub
- `pass-environment-to-command` - переменные окружения из payload
- `trigger-rule` - правила срабатывания:
  - Проверка секрета (безопасность)
  - Проверка ветки (только main)

---

### Шаг 3: Создание скрипта деплоя

**Базовый скрипт:**

```bash
cat > ~/hugo-narrow-cms/deploy.sh << 'EOF'
#!/bin/bash
set -e

# Конфигурация
PROJECT_DIR="/home/hugo/hugo-narrow-cms"
LOG_FILE="/home/hugo/webhooks/deploy.log"
BACKUP_DIR="/home/hugo/backups"

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Начало деплоя
log "=================================="
log "Deploy started"
log "Commit: ${COMMIT_ID:-unknown}"
log "Pusher: ${PUSHER:-unknown}"
log "Message: ${COMMIT_MSG:-unknown}"
log "=================================="

# Переход в директорию проекта
cd $PROJECT_DIR

# Создать backup перед обновлением
log "Creating backup..."
mkdir -p $BACKUP_DIR
tar czf $BACKUP_DIR/content_$(date +%Y%m%d_%H%M%S).tar.gz content/ static/ hugo.yaml

# Pull последних изменений
log "Pulling latest changes from GitHub..."
git fetch origin main
git reset --hard origin/main

# Остановить контейнеры
log "Stopping containers..."
docker compose --profile prod down

# Пересобрать образы
log "Building new images..."
docker compose --profile prod build --no-cache

# Запустить контейнеры
log "Starting containers..."
docker compose --profile prod up -d

# Проверить статус
log "Checking container status..."
sleep 5
if docker ps | grep -q hugo-narrow-prod; then
    log "✅ Container is running"
else
    log "❌ Container failed to start"
    exit 1
fi

# Проверить доступность сайта
log "Checking site availability..."
if curl -f http://localhost > /dev/null 2>&1; then
    log "✅ Site is accessible"
else
    log "⚠️ Site check failed"
fi

# Очистка старых образов
log "Cleaning up old images..."
docker image prune -f

# Удалить старые backups (старше 30 дней)
log "Cleaning old backups..."
find $BACKUP_DIR -name "content_*.tar.gz" -mtime +30 -delete

log "=================================="
log "Deploy completed successfully"
log "=================================="

# Отправить уведомление (опционально)
# curl -X POST https://api.telegram.org/bot<TOKEN>/sendMessage \
#   -d chat_id=<CHAT_ID> \
#   -d text="✅ Hugo site deployed successfully"

exit 0
EOF

chmod +x ~/hugo-narrow-cms/deploy.sh
```

**Расширенный скрипт с проверками:**

```bash
cat > ~/hugo-narrow-cms/deploy-advanced.sh << 'EOF'
#!/bin/bash
set -e

# Конфигурация
PROJECT_DIR="/home/hugo/hugo-narrow-cms"
LOG_FILE="/home/hugo/webhooks/deploy.log"
BACKUP_DIR="/home/hugo/backups"
ERROR_LOG="/home/hugo/webhooks/error.log"
LOCK_FILE="/tmp/deploy.lock"
MAX_RETRIES=3

# Цвета для логов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция логирования
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a $ERROR_LOG
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a $LOG_FILE
}

# Проверка блокировки (предотвращение одновременных деплоев)
if [ -f "$LOCK_FILE" ]; then
    error "Another deployment is in progress. Exiting."
    exit 1
fi

# Создать lock file
touch $LOCK_FILE
trap "rm -f $LOCK_FILE" EXIT

# Начало деплоя
log "=================================="
log "🚀 Deploy started"
log "Commit: ${COMMIT_ID:-unknown}"
log "Pusher: ${PUSHER:-unknown}"
log "Message: ${COMMIT_MSG:-unknown}"
log "=================================="

# Переход в директорию проекта
cd $PROJECT_DIR || {
    error "Failed to change directory to $PROJECT_DIR"
    exit 1
}

# Проверка свободного места
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 2 ]; then
    error "Not enough disk space. Available: ${AVAILABLE_SPACE}GB"
    exit 1
fi
log "Available disk space: ${AVAILABLE_SPACE}GB"

# Создать backup
log "📦 Creating backup..."
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar czf $BACKUP_FILE content/ static/ hugo.yaml || {
    error "Backup failed"
    exit 1
}
log "✅ Backup created: $BACKUP_FILE"

# Сохранить текущий commit для возможного отката
CURRENT_COMMIT=$(git rev-parse HEAD)
log "Current commit: $CURRENT_COMMIT"

# Pull последних изменений
log "📥 Pulling latest changes from GitHub..."
git fetch origin main || {
    error "Git fetch failed"
    exit 1
}

# Проверить, есть ли изменения
if git diff --quiet HEAD origin/main; then
    log "ℹ️ No changes detected. Skipping deployment."
    exit 0
fi

git reset --hard origin/main || {
    error "Git reset failed"
    # Откат к предыдущему состоянию
    git reset --hard $CURRENT_COMMIT
    exit 1
}
log "✅ Code updated successfully"

# Проверить docker-compose.yml
log "🔍 Validating docker-compose.yml..."
docker compose config > /dev/null || {
    error "docker-compose.yml validation failed"
    git reset --hard $CURRENT_COMMIT
    exit 1
}
log "✅ Configuration is valid"

# Остановить контейнеры
log "🛑 Stopping containers..."
docker compose --profile prod down || {
    error "Failed to stop containers"
    exit 1
}

# Пересобрать образы с повторными попытками
log "🔨 Building new images..."
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker compose --profile prod build --no-cache; then
        log "✅ Images built successfully"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            warning "Build failed. Retry $RETRY_COUNT/$MAX_RETRIES..."
            sleep 5
        else
            error "Build failed after $MAX_RETRIES attempts"
            # Откат
            git reset --hard $CURRENT_COMMIT
            docker compose --profile prod up -d
            exit 1
        fi
    fi
done

# Запустить контейнеры
log "▶️ Starting containers..."
docker compose --profile prod up -d || {
    error "Failed to start containers"
    # Откат
    git reset --hard $CURRENT_COMMIT
    docker compose --profile prod build
    docker compose --profile prod up -d
    exit 1
}

# Ожидание запуска
log "⏳ Waiting for containers to start..."
sleep 10

# Проверить статус контейнеров
log "🔍 Checking container status..."
if docker ps | grep -q hugo-narrow-prod; then
    log "✅ Container is running"
    docker ps | grep hugo-narrow-prod
else
    error "Container failed to start"
    docker compose --profile prod logs
    # Откат
    git reset --hard $CURRENT_COMMIT
    docker compose --profile prod build
    docker compose --profile prod up -d
    exit 1
fi

# Проверить health check
log "🏥 Checking container health..."
HEALTH_CHECK_COUNT=0
while [ $HEALTH_CHECK_COUNT -lt 30 ]; do
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' hugo-narrow-prod 2>/dev/null || echo "none")
    if [ "$HEALTH" = "healthy" ] || [ "$HEALTH" = "none" ]; then
        log "✅ Container is healthy"
        break
    fi
    HEALTH_CHECK_COUNT=$((HEALTH_CHECK_COUNT + 1))
    sleep 2
done

# Проверить доступность сайта
log "🌐 Checking site availability..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ]; then
    log "✅ Site is accessible (HTTP $HTTP_CODE)"
else
    warning "Site returned HTTP $HTTP_CODE"
fi

# Проверить размер ответа
RESPONSE_SIZE=$(curl -s http://localhost | wc -c)
if [ "$RESPONSE_SIZE" -gt 100 ]; then
    log "✅ Site content looks good (${RESPONSE_SIZE} bytes)"
else
    warning "Site content seems small (${RESPONSE_SIZE} bytes)"
fi

# Очистка старых образов
log "🧹 Cleaning up old images..."
docker image prune -f

# Удалить старые backups (старше 30 дней)
log "🧹 Cleaning old backups..."
DELETED_COUNT=$(find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +30 -delete -print | wc -l)
log "Deleted $DELETED_COUNT old backups"

# Показать использование ресурсов
log "📊 Resource usage:"
docker stats --no-stream hugo-narrow-prod

log "=================================="
log "✅ Deploy completed successfully"
log "=================================="

# Отправить уведомление в Telegram (опционально)
# if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
#     curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
#         -d "chat_id=${TELEGRAM_CHAT_ID}" \
#         -d "text=✅ Hugo site deployed successfully%0ACommit: ${COMMIT_ID}%0ABy: ${PUSHER}" \
#         > /dev/null
# fi

exit 0
EOF

chmod +x ~/hugo-narrow-cms/deploy-advanced.sh
```

---

### Шаг 4: Генерация секрета

```bash
# Сгенерировать случайный секрет
SECRET=$(openssl rand -hex 32)

# Сохранить секрет
echo $SECRET > ~/webhooks/secret.txt
chmod 600 ~/webhooks/secret.txt

# Показать секрет
echo "Your webhook secret:"
cat ~/webhooks/secret.txt

# Обновить конфигурацию
sed -i "s/YOUR_SECRET_HERE/$SECRET/g" ~/webhooks/hooks.json
```

---

### Шаг 5: Запуск webhook сервера

**Вариант 1: Запуск вручную (для тестирования)**

```bash
webhook -hooks ~/webhooks/hooks.json -port 9000 -verbose
```

**Вариант 2: Запуск в фоне**

```bash
nohup webhook -hooks ~/webhooks/hooks.json -port 9000 -verbose >> ~/webhooks/webhook.log 2>&1 &
```

**Вариант 3: Systemd service (рекомендуется)**

```bash
# Создать systemd service
sudo cat > /etc/systemd/system/webhook.service << 'EOF'
[Unit]
Description=Webhook Server
After=network.target

[Service]
Type=simple
User=hugo
WorkingDirectory=/home/hugo/webhooks
ExecStart=/usr/bin/webhook -hooks /home/hugo/webhooks/hooks.json -port 9000 -verbose
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузить systemd
sudo systemctl daemon-reload

# Запустить сервис
sudo systemctl start webhook

# Включить автозапуск
sudo systemctl enable webhook

# Проверить статус
sudo systemctl status webhook

# Просмотр логов
sudo journalctl -u webhook -f
```

**Открыть порт в firewall:**

```bash
sudo ufw allow 9000/tcp
sudo ufw status
```

---

### Шаг 6: Настройка GitHub

1. **Откройте настройки репозитория:**
   ```
   https://github.com/sileade/hugo-narrow-cms/settings/hooks
   ```

2. **Нажмите "Add webhook"**

3. **Заполните форму:**
   - **Payload URL**: `http://YOUR_SERVER_IP:9000/hooks/hugo-deploy`
   - **Content type**: `application/json`
   - **Secret**: (вставьте секрет из `~/webhooks/secret.txt`)
   - **Which events would you like to trigger this webhook?**
     - ☑️ Just the push event
   - **Active**: ☑️ (включено)

4. **Нажмите "Add webhook"**

5. **Проверьте статус:**
   - Зеленая галочка = успешно
   - Красный крестик = ошибка (проверьте логи)

---

## 🧪 Тестирование

### Тест 1: Локальный тест webhook

```bash
# Отправить тестовый POST запрос
curl -X POST http://localhost:9000/hooks/hugo-deploy \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: sha256=$(echo -n '{"ref":"refs/heads/main"}' | openssl dgst -sha256 -hmac "$(cat ~/webhooks/secret.txt)" | cut -d' ' -f2)" \
  -d '{"ref":"refs/heads/main","head_commit":{"id":"test123","message":"Test commit"},"pusher":{"name":"Test User"}}'
```

### Тест 2: Проверка через GitHub

1. Сделайте небольшое изменение в README.md
2. Закоммитьте и запушьте:
   ```bash
   git add README.md
   git commit -m "Test webhook"
   git push origin main
   ```
3. Проверьте логи на сервере:
   ```bash
   tail -f ~/webhooks/deploy.log
   ```

### Тест 3: Проверка в GitHub

1. Откройте: `https://github.com/sileade/hugo-narrow-cms/settings/hooks`
2. Нажмите на ваш webhook
3. Перейдите на вкладку "Recent Deliveries"
4. Проверьте статус последних запросов

---

## 🔒 Безопасность

### Использование Nginx reverse proxy

Вместо прямого доступа к webhook серверу, используйте Nginx:

```bash
# Создать конфигурацию Nginx
sudo cat > /etc/nginx/sites-available/webhook << 'EOF'
server {
    listen 80;
    server_name webhook.your-domain.com;

    location /hooks/ {
        proxy_pass http://localhost:9000/hooks/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Включить конфигурацию
sudo ln -s /etc/nginx/sites-available/webhook /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Закрыть прямой доступ
sudo ufw delete allow 9000/tcp
```

Теперь используйте URL: `http://webhook.your-domain.com/hooks/hugo-deploy`

### Добавление SSL

```bash
# Получить сертификат
sudo certbot --nginx -d webhook.your-domain.com

# Теперь используйте HTTPS
# https://webhook.your-domain.com/hooks/hugo-deploy
```

### IP Whitelist

Ограничьте доступ только с IP адресов GitHub:

```bash
# GitHub webhook IP ranges
sudo ufw allow from 192.30.252.0/22 to any port 9000
sudo ufw allow from 185.199.108.0/22 to any port 9000
sudo ufw allow from 140.82.112.0/20 to any port 9000
sudo ufw allow from 143.55.64.0/20 to any port 9000
```

---

## 🐛 Troubleshooting

### Webhook не срабатывает

**Проверить webhook сервер:**
```bash
# Проверить, запущен ли процесс
ps aux | grep webhook

# Проверить логи
tail -f ~/webhooks/webhook.log
sudo journalctl -u webhook -f

# Проверить порт
sudo netstat -tulpn | grep 9000
```

**Проверить firewall:**
```bash
sudo ufw status
# Должен быть открыт порт 9000
```

**Проверить доступность извне:**
```bash
# С другого компьютера
curl -v http://YOUR_SERVER_IP:9000/hooks/hugo-deploy
```

### Скрипт деплоя не выполняется

**Проверить права:**
```bash
ls -la ~/hugo-narrow-cms/deploy.sh
# Должен быть исполняемым: -rwxr-xr-x
```

**Проверить логи:**
```bash
tail -f ~/webhooks/deploy.log
tail -f ~/webhooks/error.log
```

**Запустить вручную:**
```bash
cd ~/hugo-narrow-cms
./deploy.sh
```

### GitHub показывает ошибку

**Проверить Recent Deliveries в GitHub:**
1. Settings → Webhooks → Ваш webhook
2. Recent Deliveries
3. Посмотреть Request и Response

**Типичные ошибки:**
- `Connection refused` - webhook сервер не запущен
- `Timeout` - firewall блокирует порт
- `401 Unauthorized` - неверный секрет
- `500 Internal Server Error` - ошибка в скрипте

### Деплой завершается с ошибкой

**Проверить Docker:**
```bash
docker ps
docker compose --profile prod logs
```

**Проверить Git:**
```bash
cd ~/hugo-narrow-cms
git status
git log -1
```

**Проверить свободное место:**
```bash
df -h
docker system df
```

---

## 📊 Мониторинг

### Просмотр логов в реальном времени

```bash
# Логи webhook сервера
tail -f ~/webhooks/webhook.log

# Логи деплоя
tail -f ~/webhooks/deploy.log

# Логи ошибок
tail -f ~/webhooks/error.log

# Системные логи
sudo journalctl -u webhook -f
```

### Статистика деплоев

```bash
# Количество деплоев
grep "Deploy started" ~/webhooks/deploy.log | wc -l

# Последние 10 деплоев
grep "Deploy started" ~/webhooks/deploy.log | tail -10

# Неудачные деплои
grep "ERROR" ~/webhooks/error.log
```

### Уведомления в Telegram

Добавьте в конец `deploy.sh`:

```bash
# Telegram уведомления
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"

if [ $? -eq 0 ]; then
    MESSAGE="✅ Hugo site deployed successfully%0ACommit: ${COMMIT_ID}%0ABy: ${PUSHER}%0AMessage: ${COMMIT_MSG}"
else
    MESSAGE="❌ Deployment failed%0ACommit: ${COMMIT_ID}%0ACheck logs for details"
fi

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${MESSAGE}" \
    > /dev/null
```

---

## 📁 Структура файлов

```
/home/hugo/
├── webhooks/
│   ├── hooks.json              # Конфигурация webhook
│   ├── secret.txt              # Секрет для GitHub
│   ├── webhook.log             # Логи webhook сервера
│   ├── deploy.log              # Логи деплоя
│   └── error.log               # Логи ошибок
├── hugo-narrow-cms/
│   ├── deploy.sh               # Скрипт деплоя
│   ├── deploy-advanced.sh      # Расширенный скрипт
│   └── ...                     # Остальные файлы проекта
└── backups/
    └── backup_*.tar.gz         # Резервные копии
```

---

## ✅ Чеклист настройки

- [ ] Установлен webhook
- [ ] Создана конфигурация hooks.json
- [ ] Создан скрипт deploy.sh
- [ ] Сгенерирован секрет
- [ ] Webhook сервер запущен
- [ ] Порт 9000 открыт в firewall
- [ ] Webhook добавлен в GitHub
- [ ] Секрет добавлен в GitHub
- [ ] Выполнен тестовый push
- [ ] Webhook сработал успешно
- [ ] Настроен systemd service
- [ ] Настроены уведомления (опционально)
- [ ] Настроен Nginx proxy (опционально)
- [ ] Добавлен SSL (опционально)

---

## 🎉 Готово!

Теперь при каждом push в ветку main:
1. GitHub отправляет webhook на ваш сервер
2. Webhook сервер проверяет секрет и ветку
3. Запускается скрипт deploy.sh
4. Код обновляется из GitHub
5. Docker контейнеры пересобираются
6. Сайт автоматически обновляется

**Время деплоя**: 1-2 минуты
**Без ручного вмешательства**: ✅

---

**Repository**: https://github.com/sileade/hugo-narrow-cms

**Happy deploying! 🚀**
