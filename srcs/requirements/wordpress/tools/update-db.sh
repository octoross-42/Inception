
# Mise à jour ciblée
echo "🔁 Wordpress: Database update..."

# URL / Title
if [ "$(echo "$CURRENT_CONFIG" | jq -r .DOMAIN_NAME)" != "$(echo "$OLD_CONFIG" | jq -r .DOMAIN_NAME)" ]; then
	echo "⌛ Wordpress: update DOMAIN_NAME"
	wp option update siteurl "$DOMAIN_NAME" --allow-root || { echo "❌ Wordpress: fail update DOMAIN_NAME siteurl"; exit 1; }
	wp option update home "$DOMAIN_NAME" --allow-root || { echo "❌ Wordpress: fail update DOMAIN_NAME home"; exit 1; }
fi
if [ "$(echo "$CURRENT_CONFIG" | jq -r .WEBSITE_TITLE)" != "$(echo "$OLD_CONFIG" | jq -r .WEBSITE_TITLE)" ]; then
	echo "⌛ Wordpress: update WEBSITE TITLE"
	wp option update blogname "$WEBSITE_TITLE" --allow-root || { echo "❌ Wordpress: fail update WEBSITE_TITLE"; exit 1; }
fi

# Admin user
OLD_ADMIN=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_NAME)
OLD_ADMIN_MAIL=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_MAIL)
OLD_ADMIN_PASS=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_PASS)
if [ "$OLD_ADMIN" != "$WP_ADMIN_NAME" ]; then
    echo "⌛ Wordpress: update admin (delete old and create new)"
    wp user delete "$OLD_ADMIN" --yes --allow-root || { echo "❌ Wordpress: fail delete old admin"; exit 1; }
    wp user create "$WP_ADMIN_NAME" "$WP_ADMIN_MAIL" \
        --user_pass="$WP_ADMIN_PASS" \
        --role=administrator \
        --allow-root || { echo "❌ Wordpress: fail create new admin"; exit 1; }
elif [ "$OLD_ADMIN_MAIL" != "$WP_ADMIN_MAIL" ] || [ "$OLD_ADMIN_PASS" != "$WP_ADMIN_PASS" ]; then
    echo "⌛ Wordpress: update admin info"
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

echo "✅ Wordpress: update database done"