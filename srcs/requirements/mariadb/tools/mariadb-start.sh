#!/bin/bash
set -e

REQUIRED_VARS=(
  DB_NAME
  DB_USER
  DB_PASS
)

# Vérifie que chaque variable est définie
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "❌ Mariadb : pls define $var in .env file"
    exit 1
  fi
done

/usr/local/bin/init-db.sh