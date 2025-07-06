#!/bin/bash

set -e

echo "⌛ Setting up wordpress..."

REQUIRED_VARS=(
  DOMAIN_NAME
  DB_NAME
  DB_USER
  DB_PASS
  WEBSITE_TITLE
  WP_ADMIN_NAME
  WP_ADMIN_PASS
  WP_ADMIN_MAIL
  WP_USER_NAME
  WP_USER_PASS
  WP_USER_MAIL
)

# Vérifie que chaque variable est définie
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "❌ Wordpress : pls define $var in .env file"
    exit 1
  fi
done

CONFIG_FILE="/app/state/.wordpress.env.json"

# Créer config actuelle en JSON
CURRENT_CONFIG=$(jq -n \
  --arg DOMAIN_NAME "$DOMAIN_NAME" \
  --arg DB_NAME "$DB_NAME" \
  --arg DB_USER "$DB_USER" \
  --arg DB_PASS "$DB_PASS" \
  --arg WEBSITE_TITLE "$WEBSITE_TITLE" \
  --arg WP_ADMIN_NAME "$WP_ADMIN_NAME" \
  --arg WP_ADMIN_PASS "$WP_ADMIN_PASS" \
  --arg WP_ADMIN_MAIL "$WP_ADMIN_MAIL" \
  --arg WP_USER_NAME "$WP_USER_NAME" \
  --arg WP_USER_PASS "$WP_USER_PASS" \
  --arg WP_USER_MAIL "$WP_USER_MAIL" \
  '{
    "DOMAIN_NAME": $DOMAIN_NAME,
    "DB_NAME": $DB_NAME,
    "DB_USER": $DB_USER,
    "DB_PASS": $DB_PASS,
    "WEBSITE_TITLE": $WEBSITE_TITLE,
    "WP_ADMIN_NAME": $WP_ADMIN_NAME,
    "WP_ADMIN_PASS": $WP_ADMIN_PASS,
    "WP_ADMIN_MAIL": $WP_ADMIN_MAIL,
    "WP_USER_NAME": $WP_USER_NAME,
    "WP_USER_PASS": $WP_USER_PASS,
    "WP_USER_MAIL": $WP_USER_MAIL,
  }')


# Attente de la disponibilité de la base de données avec wait-for-it
/usr/local/bin/wait-for-it.sh  "mariadb:3306" -t 30 -- echo "✅ Database retrieved !"


# Si pas de config précédente, installation complète
if [ ! -f "$CONFIG_FILE" ] || [ ! -f ./wp-config.php ]; then
  echo "$CURRENT_CONFIG" > "$CONFIG_FILE"
  /usr/local/bin/init-wp-config.sh
  exit 0
fi

# Comparaison config précédente
OLD_CONFIG=$(cat "$CONFIG_FILE")
OLD_CONFIG="$OLD_CONFIG" /usr/local/bin/update-wp-config.sh

echo "$CURRENT_CONFIG" > "$CONFIG_FILE"
echo "✅ wp-config success"
