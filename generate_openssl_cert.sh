#!/bin/bash

# Config
DOMAIN="${1:-yourlogin.42.fr}"
CERT_DIR="srcs/requirements/nginx/certs"
KEY_PATH="$CERT_DIR/$DOMAIN.key"
CRT_PATH="$CERT_DIR/$DOMAIN.crt"

# Create cert directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Check if cert and key exist
if [[ -f "$KEY_PATH" && -f "$CRT_PATH" ]]; then
    echo "✅ Certificate and key already exist:"
    echo " - $CRT_PATH"
    echo " - $KEY_PATH"
else
    echo "🔧 Generating self-signed certificate for $DOMAIN..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY_PATH" \
        -out "$CRT_PATH" \
        -subj "/C=SG/ST=42/L=Intra/O=42/CN=$DOMAIN"

    if [[ $? -eq 0 ]]; then
        echo "✅ Certificate generated successfully:"
        echo " - $CRT_PATH"
        echo " - $KEY_PATH"
    else
        echo "❌ Failed to generate certificate."
        exit 1
    fi
fi
