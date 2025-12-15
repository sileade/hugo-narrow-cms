.PHONY: help dev prod stop clean logs build rebuild shell test

# Default target
.DEFAULT_GOAL := help

# Docker Compose command
DC := docker-compose

help: ## Show this help message
	@echo "Hugo Narrow CMS - Docker Commands"
	@echo "=================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Start development server with live reload
	@echo "🚀 Starting development server..."
	$(DC) --profile dev up -d
	@echo ""
	@echo "✅ Development server started!"
	@echo "   Website: http://localhost:1313"
	@echo "   Admin: http://localhost:1313/admin/"
	@echo ""

prod: ## Start production server with Nginx
	@echo "🏭 Starting production server..."
	$(DC) --profile prod up -d --build
	@echo ""
	@echo "✅ Production server started!"
	@echo "   Website: http://localhost"
	@echo "   Admin: http://localhost/admin/"
	@echo ""

stop: ## Stop all containers
	@echo "🛑 Stopping all containers..."
	$(DC) --profile dev --profile prod down
	@echo "✅ All containers stopped!"

clean: ## Remove all containers, images, and volumes
	@echo "🧹 Cleaning up..."
	$(DC) --profile dev --profile prod down --rmi all --volumes
	@echo "✅ Cleanup complete!"

logs: ## View logs from all containers
	$(DC) logs -f

logs-dev: ## View logs from development container
	$(DC) --profile dev logs -f hugo-dev

logs-prod: ## View logs from production container
	$(DC) --profile prod logs -f hugo-prod

build: ## Build Docker images
	@echo "🔨 Building Docker images..."
	$(DC) build
	@echo "✅ Build complete!"

rebuild: ## Rebuild Docker images without cache
	@echo "🔨 Rebuilding Docker images..."
	$(DC) build --no-cache
	@echo "✅ Rebuild complete!"

shell: ## Open shell in development container
	docker exec -it hugo-narrow-dev sh

shell-prod: ## Open shell in production container
	docker exec -it hugo-narrow-prod sh

ps: ## List running containers
	$(DC) ps

restart-dev: ## Restart development container
	$(DC) --profile dev restart

restart-prod: ## Restart production container
	$(DC) --profile prod restart

test: ## Test Hugo build locally
	@echo "🧪 Testing Hugo build..."
	hugo --minify
	@echo "✅ Build test successful!"

hugo-version: ## Show Hugo version
	docker run --rm klakegg/hugo:0.146.0-ext-alpine version

stats: ## Show container resource usage
	docker stats

prune: ## Remove unused Docker resources
	docker system prune -af --volumes

backup: ## Backup content directory
	@echo "💾 Creating backup..."
	tar czf backup-$$(date +%Y%m%d-%H%M%S).tar.gz content/ static/ hugo.yaml
	@echo "✅ Backup created!"

update: ## Pull latest Hugo image
	docker pull klakegg/hugo:0.146.0-ext-alpine

install: ## Install Docker (Linux only)
	@echo "📦 Installing Docker..."
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker $$USER
	@echo "✅ Docker installed! Please log out and back in."
