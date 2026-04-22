#!/bin/bash

# Certbot setup script for Groq Chat App
# This script helps set up Let's Encrypt certificates

set -e

DOMAIN=${DOMAIN:-"localhost"}
EMAIL=${EMAIL:-"admin@${DOMAIN}"}
CERTBOT_PATH=${CERTBOT_PATH:-"/etc/letsencrypt"}

echo "Setting up Let's Encrypt for domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Certbot path: $CERTBOT_PATH"

# Check if domain is set
if [ "$DOMAIN" = "localhost" ]; then
    echo "WARNING: Using localhost. For production, set DOMAIN environment variable to your actual domain."
    echo "Continuing with self-signed certificate for testing..."
    
    # Create directories
    mkdir -p "$CERTBOT_PATH/live/$DOMAIN"
    mkdir -p "$CERTBOT_PATH/archive/$DOMAIN"
    mkdir -p "$CERTBOT_PATH/renewal"
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERTBOT_PATH/live/$DOMAIN/privkey.pem" \
        -out "$CERTBOT_PATH/live/$DOMAIN/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"
    
    echo "Self-signed certificate generated at: $CERTBOT_PATH/live/$DOMAIN/"
    exit 0
fi

# Check if certbot is available
if ! command -v certbot &> /dev/null && ! docker --help &> /dev/null; then
    echo "ERROR: certbot or docker is required for Let's Encrypt certificates"
    echo "Install certbot: sudo apt-get install certbot python3-certbot-nginx"
    echo "Or use Docker with the provided docker-compose.ssl.yml"
    exit 1
fi

# Create necessary directories
mkdir -p ./var/www/certbot
mkdir -p "$CERTBOT_PATH"

echo "To obtain Let's Encrypt certificate, run one of the following:"

if command -v certbot &> /dev/null; then
    echo ""
    echo "Option 1: Using local certbot:"
    echo "sudo certbot certonly --webroot -w ./var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email"
fi

echo ""
echo "Option 2: Using Docker (recommended):"
echo "docker run -it --rm -v $CERTBOT_PATH:/etc/letsencrypt -v ./var/www/certbot:/var/www/certbot certbot/certbot certonly --webroot -w /var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email"

echo ""
echo "After obtaining certificates, update your .env file:"
echo "CERTBOT_PATH=$CERTBOT_PATH"
echo "DOMAIN=$DOMAIN"

echo ""
echo "Then start the application with:"
echo "docker-compose -f docker-compose.ssl.yml up --build"
