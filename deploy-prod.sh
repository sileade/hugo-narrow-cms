#!/bin/bash
set -e

echo "🚀 Hugo Narrow CMS - Production Deployment"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo -e "${RED}❌ Please edit .env file with your configuration:${NC}"
    echo "   - DOMAIN=yourdomain.com"
    echo "   - ACME_EMAIL=your-email@example.com"
    echo "   - ADMIN_PASSWORD=strong-password"
    echo "   - etc."
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Load environment variables
source .env

# Check required variables
REQUIRED_VARS=("DOMAIN" "ACME_EMAIL" "ADMIN_PASSWORD" "POSTGRES_PASSWORD")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please set these in your .env file."
    exit 1
fi

echo -e "${GREEN}✅ Environment variables loaded${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are installed${NC}"
echo ""

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p letsencrypt postgres uptime-kuma backups admin/db
chmod 600 letsencrypt 2>/dev/null || true
echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Build Hugo site
echo "🔨 Building Hugo site..."
if command -v hugo &> /dev/null; then
    hugo --minify
    echo -e "${GREEN}✅ Hugo site built${NC}"
else
    echo -e "${YELLOW}⚠️  Hugo not found locally, will build in Docker${NC}"
fi
echo ""

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
echo -e "${GREEN}✅ Containers stopped${NC}"
echo ""

# Pull latest images
echo "📥 Pulling Docker images..."
docker-compose -f docker-compose.prod.yml pull
echo -e "${GREEN}✅ Images pulled${NC}"
echo ""

# Build custom images
echo "🔨 Building custom images..."
docker-compose -f docker-compose.prod.yml build
echo -e "${GREEN}✅ Images built${NC}"
echo ""

# Start services
echo "🚀 Starting services..."
docker-compose -f docker-compose.prod.yml up -d
echo -e "${GREEN}✅ Services started${NC}"
echo ""

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
echo "=================="
docker-compose -f docker-compose.prod.yml ps
echo ""

# Show URLs
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo ""
echo "📍 Your services are available at:"
echo "   🌐 Website:    https://${DOMAIN}"
echo "   🎛️  Admin:      https://${DOMAIN}/admin"
echo "   📊 Monitoring: https://monitor.${DOMAIN}"
echo "   📈 Analytics:  https://analytics.${DOMAIN}"
echo "   🔧 Traefik:    https://traefik.${DOMAIN}"
echo ""
echo "📝 Next steps:"
echo "   1. Configure DNS A record: ${DOMAIN} → $(curl -s ifconfig.me)"
echo "   2. Wait for SSL certificates (1-2 minutes)"
echo "   3. Login to admin panel with:"
echo "      Username: ${ADMIN_USERNAME:-admin}"
echo "      Password: (from .env)"
echo ""
echo "📚 Useful commands:"
echo "   View logs:    docker-compose -f docker-compose.prod.yml logs -f"
echo "   Stop:         docker-compose -f docker-compose.prod.yml down"
echo "   Restart:      docker-compose -f docker-compose.prod.yml restart"
echo "   Update:       git pull && ./deploy-prod.sh"
echo ""
echo -e "${GREEN}✨ Happy blogging!${NC}"
