#!/usr/bin/env sh
set -e

# Mise à jour ciblée
echo "🔁 Wordpress: Database update..."

# URL / Title

OLD_DOMAIN_NAME="$(echo "$OLD_CONFIG" | jq -r .DOMAIN_NAME)"
if [ "$DOMAIN_NAME" != "$OLD_DOMAIN_NAME" ]; then
	echo "⌛ Wordpress: update DOMAIN_NAME from $OLD_DOMAIN_NAME to $DOMAIN_NAME"
	wp search-replace "$OLD_DOMAIN_NAME" "$DOMAIN_NAME" --all-tables --allow-root || { echo "❌ Wordpress: fail update DOMAIN_NAME in tables"; exit 1; }
	wp option update siteurl "$DOMAIN_NAME" --allow-root || { echo "❌ Wordpress: fail update DOMAIN_NAME siteurl"; exit 1; }
	wp option update home "$DOMAIN_NAME" --allow-root || { echo "❌ Wordpress: fail update DOMAIN_NAME home"; exit 1; }
fi

OLD_WEBSITE_TITLE="$(echo "$OLD_CONFIG" | jq -r .WEBSITE_TITLE)"
if [ "$WEBSITE_TITLE" != "$OLD_WEBSITE_TITLE" ]; then
	echo "⌛ Wordpress: update WEBSITE TITLE to $WEBSITE_TITLE"
	wp option update blogname "$WEBSITE_TITLE" --allow-root || { echo "❌ Wordpress: fail update WEBSITE_TITLE"; exit 1; }
fi

# Admin user
OLD_ADMIN=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_NAME)
OLD_ADMIN_MAIL=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_MAIL)
OLD_ADMIN_PASS=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_PASS)
if [ "$OLD_ADMIN" != "$WP_ADMIN_NAME" ]; then
    echo "⌛ Wordpress: update admin (delete old and create new): $WP_ADMIN_NAME $WP_AMDIN_MAIL"
    wp user delete "$OLD_ADMIN" --yes --allow-root || { echo "❌ Wordpress: fail delete old admin"; exit 1; }
    wp user create "$WP_ADMIN_NAME" "$WP_ADMIN_MAIL" \
        --user_pass="$WP_ADMIN_PASS" \
        --role=administrator \
        --allow-root || { echo "❌ Wordpress: fail create new admin"; exit 1; }
elif [ "$OLD_ADMIN_MAIL" != "$WP_ADMIN_MAIL" ] || [ "$OLD_ADMIN_PASS" != "$WP_ADMIN_PASS" ]; then
    echo "⌛ Wordpress: update admin info $WP_ADMIN_MAIL"
    wp user update "$WP_ADMIN_NAME" \
        --user_email="$WP_ADMIN_MAIL" \
        --user_pass="$WP_ADMIN_PASS" \
        --allow-root || { echo "❌ Wordpress: fail update admin info"; exit 1; }
fi

# Secondary user
OLD_USER=$(echo "$OLD_CONFIG" | jq -r .WP_USER_NAME)
OLD_USER_MAIL=$(echo "$OLD_CONFIG" | jq -r .WP_USER_MAIL)
OLD_USER_PASS=$(echo "$OLD_CONFIG" | jq -r .WP_USER_PASS)
if [ "$OLD_USER" != "$WP_USER_NAME" ]; then

    echo "⌛ Wordpress: update user (delete old and create new)"
    wp user delete "$OLD_USER" --yes --allow-root ||  { echo "❌ Wordpress: fail delete old user"; exit 1; }
    wp user create "$WP_USER_NAME" "$WP_USER_MAIL" \
        --user_pass="$WP_USER_PASS" \
        --role="editor" \
        --allow-root || { echo "❌ Wordpress: fail create new user"; exit 1; }
elif [ "$OLD_USER_MAIL" != "$WP_USER_MAIL" ] || [ "$OLD_USER_PASS" != "$WP_USER_PASS" ]; then
    echo "⌛ Wordpress: update user info"
    wp user update "$WP_USER_NAME" \
        --user_email="$WP_USER_MAIL" \
        --user_pass="$WP_USER_PASS" \
        --role="editor" \
        --allow-root || { echo "❌ Wordpress: fail update user info"; exit 1; }
fi


OLD_DB_NAME=$(echo "$OLD_CONFIG" | jq -r .DB_NAME)
if [ "$OLD_DB_NAME" != "$DB_NAME" ]; then
	echo "⌛ Wordpress: update DB_NAME"
	mysql -u "$DB_USER" -p"$DB_PASS" -h mariadb -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" || { echo "❌ Wordpress: fail create new db"; exit 1;}
	mysqldump -u "$DB_USER" -p"$DB_PASS" -h mariadb "$OLD_DB_NAME" | mysql -u "$DB_USER" -p"$DB_PASS" -h mariadb "$DB_NAME" || { echo "❌ Wordpress: fail copy new db from old one"; exit 1;}
	mysql -u "$DB_USER" -p"$DB_PASS" -h mariadb -e "DROP DATABASE \`$OLD_DB_NAME\`;" || { echo "❌ Wordpress: fail delete old db"; exit 1;}
	wp config set DB_NAME "$DB_NAME" --allow-root ||  { echo "❌ Wordpress: fail update DB_NAME in wp-config"; exit 1; }

fi


echo "✅ Wordpress: update database done"