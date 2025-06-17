#!/usr/bin/env sh
set -e

if [ -f .env ]; then
  . .env
fi

if [ -z "$DOMAIN_NAME" ]; then
  echo "❌ Pls define DOMAIN_NAME in env file" >&2
  exit 1
fi


# 127.0.0.1   DOMAIN_NAME -> IPv4
# ::1         DOMAIN_NAME -> IPv6

if ! grep -qE "^[[:space:]]*127\.0\.0\.1[[:space:]]+$DOMAIN_NAME" /etc/hosts; then
  echo "★ Added $DOMAIN_NAME to /etc/hosts"
  printf "127.0.0.1\t%s\n::1\t%s\n" "$DOMAIN_NAME" "$DOMAIN_NAME" \
    | sudo tee -a /etc/hosts >/dev/null
else
  echo "ℹ️ $DOMAIN_NAME found in /etc/hosts"
fi


docker-compose up -d --build
# --build -> reconstruire images dockers
# -d = --detach -> arriere plan