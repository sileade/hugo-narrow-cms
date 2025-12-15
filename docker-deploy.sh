#!/bin/bash

# Hugo Narrow CMS - Docker Quick Deploy Script
# This script helps you quickly deploy Hugo site using Docker Compose

set -e

echo "🐳 Hugo Narrow CMS - Docker Deployment"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first:"
    echo "   https://docs.docker.com/compose/install/"
    exit 1
fi

# Determine docker compose command
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Show menu
echo "Select deployment mode:"
echo "1) Development (with live reload)"
echo "2) Production (optimized build)"
echo "3) Stop all containers"
echo "4) Clean up (remove containers and images)"
echo ""
read -p "Enter your choice (1-4): " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "🚀 Starting Development Mode..."
        echo "================================"
        echo ""
        echo "Features:"
        echo "  - Live reload on file changes"
        echo "  - Draft posts visible"
        echo "  - Admin panel available"
        echo ""
        
        $DOCKER_COMPOSE --profile dev up -d
        
        echo ""
        echo "✅ Development server started!"
        echo ""
        echo "Access your site:"
        echo "  🌐 Website: http://localhost:1313"
        echo "  📝 Admin Panel: http://localhost:1313/admin/"
        echo "  🔧 Proxy (with admin): http://localhost:8080"
        echo ""
        echo "To view logs:"
        echo "  $DOCKER_COMPOSE --profile dev logs -f"
        echo ""
        echo "To stop:"
        echo "  $DOCKER_COMPOSE --profile dev down"
        ;;
    
    2)
        echo ""
        echo "🏭 Starting Production Mode..."
        echo "=============================="
        echo ""
        echo "Features:"
        echo "  - Optimized build"
        echo "  - Nginx web server"
        echo "  - Gzip compression"
        echo "  - Static file caching"
        echo ""
        
        $DOCKER_COMPOSE --profile prod up -d --build
        
        echo ""
        echo "✅ Production server started!"
        echo ""
        echo "Access your site:"
        echo "  🌐 Website: http://localhost"
        echo "  📝 Admin Panel: http://localhost/admin/"
        echo ""
        echo "To view logs:"
        echo "  $DOCKER_COMPOSE --profile prod logs -f"
        echo ""
        echo "To stop:"
        echo "  $DOCKER_COMPOSE --profile prod down"
        ;;
    
    3)
        echo ""
        echo "🛑 Stopping all containers..."
        $DOCKER_COMPOSE --profile dev --profile prod down
        echo ""
        echo "✅ All containers stopped!"
        ;;
    
    4)
        echo ""
        echo "🧹 Cleaning up..."
        read -p "This will remove all containers and images. Continue? (y/n): " CONFIRM
        
        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
            $DOCKER_COMPOSE --profile dev --profile prod down --rmi all --volumes
            echo ""
            echo "✅ Cleanup complete!"
        else
            echo "Cleanup cancelled."
        fi
        ;;
    
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "📚 For more information, see DOCKER.md"
echo ""
