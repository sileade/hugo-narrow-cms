# Multi-stage Dockerfile for Hugo Narrow CMS

# Stage 1: Builder
FROM klakegg/hugo:0.146.0-ext-alpine AS builder

# Set working directory
WORKDIR /src

# Copy project files
COPY . .

# Build the site
RUN hugo --minify

# Stage 2: Development
FROM klakegg/hugo:0.146.0-ext-alpine AS development

# Set working directory
WORKDIR /src

# Expose Hugo server port
EXPOSE 1313

# Start Hugo server with live reload
CMD ["hugo", "server", "--bind", "0.0.0.0", "--buildDrafts", "--buildFuture", "--disableFastRender"]

# Stage 3: Production with Nginx
FROM nginx:alpine AS production

# Copy built site from builder
COPY --from=builder /src/public /usr/share/nginx/html

# Copy custom nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
