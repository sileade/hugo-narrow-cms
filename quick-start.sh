#!/bin/bash
# Quick Start - Hugo Narrow CMS

echo "🚀 Hugo Narrow CMS - Quick Start"
echo "================================"
echo ""
echo "Choose deployment mode:"
echo "  1) Development (local, live reload)"
echo "  2) Production (with SSL, monitoring, backups)"
echo "  3) Test build only"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo "Starting development mode..."
        docker-compose up -d
        echo "✅ Development server running at http://localhost:1313"
        echo "✅ Admin panel at http://localhost:1313/admin"
        ;;
    2)
        echo "Starting production deployment..."
        ./deploy-prod.sh
        ;;
    3)
        echo "Running test build..."
        hugo --minify && echo "✅ Build successful!"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
