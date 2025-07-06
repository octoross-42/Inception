#!/usr/bin/env sh

# exit script as soon as a cmd has non-zero exit  
set -e

if [ -z "$DOMAIN_NAME" ]; then
  echo "❌ Nginx: pls define DOMAIN_NAME in .env file" >&2
  exit 1
fi

CERT_DIR=/etc/ssl/certs
CRT="$CERT_DIR/${DOMAIN_NAME}.crt"
KEY="$CERT_DIR/${DOMAIN_NAME}.key"

# C		= Country
# ST	= State or Province
# L		= Locality (ville)
# O		= Organization
# OU	= Organizational Unit
# CN	= Common Name (le nom du domaine)

mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -days 30 \
	-newkey rsa:2048 \
	-keyout "$KEY" \
	-out "$CRT" \
	-subj "/C=FR/ST=Île-de-France/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}" \
	|| { echo "❌ Nginx: cant create secutity keys (openssl)"; exit 1; }

echo "✅ Nginx: Self-signed certificate generated for ${DOMAIN_NAME}"
