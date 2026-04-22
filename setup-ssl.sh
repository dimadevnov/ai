#!/bin/bash

# SSL setup script for Groq Chat App
# This script helps set up SSL certificates using Let's Encrypt

set -e

DOMAIN=${DOMAIN:-"localhost"}
EMAIL=${EMAIL:-"admin@${DOMAIN}"}

echo "Setting up SSL for domain: $DOMAIN"

# Create necessary directories
mkdir -p ./ssl/live/${DOMAIN}
mkdir -p ./ssl/work
mkdir -p ./var/www/certbot

# Check if we're using a custom certificate
if [ -f "./ssl/cert.pem" ] && [ -f "./ssl/key.pem" ]; then
    echo "Using existing custom SSL certificates..."
    cp ./ssl/cert.pem ./ssl/live/${DOMAIN}/fullchain.pem
    cp ./ssl/key.pem ./ssl/live/${DOMAIN}/privkey.pem
else
    echo "Generating self-signed certificate for development..."
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ./ssl/live/${DOMAIN}/privkey.pem \
        -out ./ssl/live/${DOMAIN}/fullchain.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN}"
    
    echo "Self-signed certificate generated. For production, use Let's Encrypt:"
    echo "1. Set DOMAIN and EMAIL environment variables"
    echo "2. Run: certbot certonly --webroot -w ./var/www/certbot -d $DOMAIN --email $EMAIL --agree-tos --no-eff-email"
    echo "3. Copy certificates from /etc/letsencrypt/live/$DOMAIN to ./ssl/live/$DOMAIN"
fi

echo "SSL setup complete!"
echo "Certificates located at: ./ssl/live/${DOMAIN}/"
