#!/usr/bin/env sh

# exit script as soon as a cmd has non-zero exit  
set -e

if [ -z "$DOMAIN_NAME" ]; then
#   >&2: stderr
  echo "❌ Pls define DOMAIN_NAME in env file" >&2
  exit 1
fi

CERT_DIR=/etc/ssl/certs
CRT="$CERT_DIR/${DOMAIN_NAME}.crt"
KEY="$CERT_DIR/${DOMAIN_NAME}.key"

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  mkdir -p "$CERT_DIR"
  openssl req -x509 -nodes -days 1 \
    -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CRT" \
    -subj "/C=FR/ST=Île-de-France/L=Paris/O=42/Inception/CN=${DOMAIN_NAME}"
  echo "★ Self-signed certificate generated for ${DOMAIN_NAME}"
fi

exec nginx -g 'daemon off;'
