FROM python:3.11-slim

WORKDIR /app

# Install git for committing
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create directories
RUN mkdir -p /app/content /app/static /app/db

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
