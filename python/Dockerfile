FROM python:3.13-slim

# Set environment variables for security and performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_NAME=my-app

WORKDIR /app

# Install system dependencies and clean up in one layer
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y gcc libffi-dev \
    && pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir flask==3.0.3 \
    && apt-get purge -y --auto-remove gcc libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the application code
COPY app.py /app
COPY VERSION /app
COPY templates /app/templates

EXPOSE 8080

CMD ["python", "app.py"]