#!/bin/bash
set -e

REQUIRED_VARS=(
  DOMAIN_NAME
  DB_NAME
  DB_HOST
  DB_PORT
  DB_USER
  DB_PASS
  DB_PREFIX
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

CONFIG_FILE=".env.json"

# Créer config actuelle en JSON
CURRENT_CONFIG=$(jq -n \
  --arg DOMAIN_NAME "$DOMAIN_NAME" \
  --arg DB_NAME "$DB_NAME" \
  --arg DB_HOST "$DB_HOST" \
  --arg DB_PORT "$DB_PORT" \
  --arg DB_USER "$DB_USER" \
  --arg DB_PASS "$DB_PASS" \
  --arg DB_PREFIX "$DB_PREFIX" \
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
    "DB_HOST": $DB_HOST,
    "DB_PORT": $DB_PORT,
    "DB_USER": $DB_USER,
    "DB_PASS": $DB_PASS,
    "DB_PREFIX": $DB_PREFIX,
    "WEBSITE_TITLE": $WEBSITE_TITLE,
    "WP_ADMIN_NAME": $WP_ADMIN_NAME,
    "WP_ADMIN_PASS": $WP_ADMIN_PASS,
    "WP_ADMIN_MAIL": $WP_ADMIN_MAIL,
    "WP_USER_NAME": $WP_USER_NAME,
    "WP_USER_PASS": $WP_USER_PASS,
    "WP_USER_MAIL": $WP_USER_MAIL,
  }')


# Attente de la disponibilité de la base de données avec wait-for-it
/wait-for-it.sh "$DB_HOST:$DB_PORT" -t 30 -- echo "✅ Database retrieved !"


# Si pas de config précédente, installation complète
if [ ! -f "$CONFIG_FILE" ]; then
  echo "$CURRENT_CONFIG" > "$CONFIG_FILE"
  /usr/local/bin/init-db.sh
  exit 0
fi



# Comparaison config précédente
OLD_CONFIG=$(cat "$CONFIG_FILE")

RESET_NEEDED=false
if [ "$(echo "$CURRENT_CONFIG" | jq -r .DB_NAME)" != "$(echo "$OLD_CONFIG" | jq -r .DB_NAME)" ]; then
  RESET_NEEDED=true
fi
if [ "$(echo "$CURRENT_CONFIG" | jq -r .DB_PREFIX)" != "$(echo "$OLD_CONFIG" | jq -r .DB_PREFIX)" ]; then
  RESET_NEEDED=true
fi

if $RESET_NEEDED; then
  echo "💣 Wordpress: DB_NAME or DB_PREFIX change detected: database reset"
  wp db reset --yes --allow-root
  /usr/local/bin/init-db.sh
  exit 0
fi

CURRENT_CONFIG="$CURRENT_CONFIG" OLD_CONFIG="$OLD_CONFIG" /usr/local/bin/update-db.sh

echo "$CURRENT_CONFIG" > "$CONFIG_FILE"
echo "✅ wp-config success"
