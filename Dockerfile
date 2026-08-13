FROM python:3.12-slim

WORKDIR /app

# Install system dependencies if any
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app.py .
COPY templates/ ./templates/

# Expose Web Port
EXPOSE 5000

# Run Flask app
CMD ["python", "app.py"]
