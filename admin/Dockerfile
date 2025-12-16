FROM python:3.11-slim

WORKDIR /app/admin

# Install git and Hugo 0.146.0 (required by theme)
RUN apt-get update && \
    apt-get install -y git curl && \
    # Install Hugo extended version 0.146.0 with retry
    curl -L --retry 5 --retry-delay 3 -o hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.146.0/hugo_extended_0.146.0_linux-amd64.deb && \
    dpkg -i hugo.deb && \
    rm hugo.deb && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create directories
RUN mkdir -p /app/content /app/static /app/public /app/admin/db

# Expose port
EXPOSE 5000

# Run application from admin directory
CMD ["python", "app.py"]
