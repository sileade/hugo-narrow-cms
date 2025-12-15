#!/bin/bash
set -e

# ============================================
# Hugo Narrow CMS - Auto Deploy Script
# Triggered by GitHub webhook on push to main
# ============================================

# Configuration
PROJECT_DIR="/home/hugo/hugo-narrow-cms"
LOG_FILE="/home/hugo/webhooks/deploy.log"
BACKUP_DIR="/home/hugo/backups"
ERROR_LOG="/home/hugo/webhooks/error.log"
LOCK_FILE="/tmp/deploy.lock"
MAX_RETRIES=3

# Colors for logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a $ERROR_LOG
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a $LOG_FILE
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a $LOG_FILE
}

# Check for concurrent deployments
if [ -f "$LOCK_FILE" ]; then
    error "Another deployment is in progress. Exiting."
    exit 1
fi

# Create lock file
touch $LOCK_FILE
trap "rm -f $LOCK_FILE" EXIT

# Start deployment
log "=========================================="
log "🚀 Deployment Started"
log "=========================================="
info "Commit ID: ${COMMIT_ID:-unknown}"
info "Pushed by: ${PUSHER:-unknown}"
info "Message: ${COMMIT_MSG:-unknown}"
log "=========================================="

# Change to project directory
cd $PROJECT_DIR || {
    error "Failed to change directory to $PROJECT_DIR"
    exit 1
}

# Check available disk space
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 2 ]; then
    error "Not enough disk space. Available: ${AVAILABLE_SPACE}GB"
    exit 1
fi
info "Available disk space: ${AVAILABLE_SPACE}GB"

# Create backup before updating
log "📦 Creating backup..."
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
tar czf $BACKUP_FILE content/ static/ hugo.yaml || {
    error "Backup failed"
    exit 1
}
log "✅ Backup created: $(basename $BACKUP_FILE)"

# Save current commit for potential rollback
CURRENT_COMMIT=$(git rev-parse HEAD)
info "Current commit: $CURRENT_COMMIT"

# Fetch latest changes from GitHub
log "📥 Fetching latest changes from GitHub..."
git fetch origin main || {
    error "Git fetch failed"
    exit 1
}

# Check if there are any changes
if git diff --quiet HEAD origin/main; then
    info "No changes detected. Skipping deployment."
    exit 0
fi

# Pull changes
log "⬇️ Pulling changes..."
git reset --hard origin/main || {
    error "Git reset failed"
    git reset --hard $CURRENT_COMMIT
    exit 1
}
NEW_COMMIT=$(git rev-parse HEAD)
log "✅ Updated to commit: $NEW_COMMIT"

# Validate docker-compose.yml
log "🔍 Validating docker-compose.yml..."
docker compose config > /dev/null || {
    error "docker-compose.yml validation failed"
    git reset --hard $CURRENT_COMMIT
    exit 1
}
log "✅ Configuration is valid"

# Stop containers
log "🛑 Stopping containers..."
docker compose --profile prod down || {
    error "Failed to stop containers"
    exit 1
}
log "✅ Containers stopped"

# Build new images with retry logic
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
            # Rollback
            git reset --hard $CURRENT_COMMIT
            docker compose --profile prod up -d
            exit 1
        fi
    fi
done

# Start containers
log "▶️ Starting containers..."
docker compose --profile prod up -d || {
    error "Failed to start containers"
    # Rollback
    git reset --hard $CURRENT_COMMIT
    docker compose --profile prod build
    docker compose --profile prod up -d
    exit 1
}

# Wait for containers to start
log "⏳ Waiting for containers to start..."
sleep 10

# Check container status
log "🔍 Checking container status..."
if docker ps | grep -q hugo-narrow-prod; then
    log "✅ Container is running"
    docker ps --filter "name=hugo-narrow-prod" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    error "Container failed to start"
    docker compose --profile prod logs --tail=50
    # Rollback
    git reset --hard $CURRENT_COMMIT
    docker compose --profile prod build
    docker compose --profile prod up -d
    exit 1
fi

# Health check
log "🏥 Performing health check..."
HEALTH_CHECK_COUNT=0
MAX_HEALTH_CHECKS=30
while [ $HEALTH_CHECK_COUNT -lt $MAX_HEALTH_CHECKS ]; do
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' hugo-narrow-prod 2>/dev/null || echo "none")
    if [ "$HEALTH" = "healthy" ] || [ "$HEALTH" = "none" ]; then
        log "✅ Container is healthy"
        break
    fi
    HEALTH_CHECK_COUNT=$((HEALTH_CHECK_COUNT + 1))
    if [ $HEALTH_CHECK_COUNT -eq $MAX_HEALTH_CHECKS ]; then
        warning "Health check timeout"
    fi
    sleep 2
done

# Check site availability
log "🌐 Checking site availability..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ]; then
    log "✅ Site is accessible (HTTP $HTTP_CODE)"
else
    warning "Site returned HTTP $HTTP_CODE"
fi

# Check response size
RESPONSE_SIZE=$(curl -s http://localhost | wc -c)
if [ "$RESPONSE_SIZE" -gt 100 ]; then
    log "✅ Site content looks good (${RESPONSE_SIZE} bytes)"
else
    warning "Site content seems small (${RESPONSE_SIZE} bytes)"
fi

# Cleanup old Docker images
log "🧹 Cleaning up old Docker images..."
PRUNED=$(docker image prune -f 2>&1 | grep "Total reclaimed space" || echo "0B")
info "Reclaimed: $PRUNED"

# Cleanup old backups (older than 30 days)
log "🧹 Cleaning old backups..."
DELETED_COUNT=$(find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +30 -delete -print | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    info "Deleted $DELETED_COUNT old backups"
fi

# Show resource usage
log "📊 Current resource usage:"
docker stats --no-stream hugo-narrow-prod | tail -1

# Deployment summary
log "=========================================="
log "✅ Deployment Completed Successfully"
log "=========================================="
info "Old commit: $CURRENT_COMMIT"
info "New commit: $NEW_COMMIT"
info "Deployment time: $(date)"
log "=========================================="

# Send notification (optional - uncomment and configure)
# TELEGRAM_BOT_TOKEN="your_bot_token"
# TELEGRAM_CHAT_ID="your_chat_id"
# if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
#     MESSAGE="✅ Hugo site deployed successfully%0A%0ACommit: ${COMMIT_ID}%0ABy: ${PUSHER}%0AMessage: ${COMMIT_MSG}%0A%0ATime: $(date '+%Y-%m-%d %H:%M:%S')"
#     curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
#         -d "chat_id=${TELEGRAM_CHAT_ID}" \
#         -d "text=${MESSAGE}" \
#         -d "parse_mode=HTML" \
#         > /dev/null
# fi

exit 0
