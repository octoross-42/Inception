
# Mise à jour ciblée
echo "🔁 Wordpress: Database update..."

# URL / Title
echo "Wordpress: update DOMAIN_NAME"
if [ "$(echo "$CURRENT_CONFIG" | jq -r .DOMAIN_NAME)" != "$(echo "$OLD_CONFIG" | jq -r .DOMAIN_NAME)" ]; then
  wp option update siteurl "$DOMAIN_NAME" --allow-root || exit 1
  wp option update home "$DOMAIN_NAME" --allow-root || exit 1
fi
echo "Wordpress: update WEBSITE TITLE"
if [ "$(echo "$CURRENT_CONFIG" | jq -r .WEBSITE_TITLE)" != "$(echo "$OLD_CONFIG" | jq -r .WEBSITE_TITLE)" ]; then
  wp option update blogname "$WEBSITE_TITLE" --allow-root || exit 1
fi

# Admin user
OLD_ADMIN=$(echo "$OLD_CONFIG" | jq -r .WP_ADMIN_NAME)
if [ "$OLD_ADMIN" != "$WP_ADMIN_NAME" ]; then
    echo "Wordpress: update admin (delete old and create new)"
    wp user create "$WP_ADMIN_NAME" "$WP_ADMIN_MAIL" \
        --user_pass="$WP_ADMIN_PASS" \
        --role=administrator \
        --allow-root || exit 1
    wp user delete "$OLD_ADMIN" --yes --allow-root || exit 1
else
    echo "Wordpress: update admin info"
    wp user update "$WP_ADMIN_NAME" \
        --user_email="$WP_ADMIN_MAIL" \
        --user_pass="$WP_ADMIN_PASS" \
        --allow-root || exit 1
fi

# Secondary user
OLD_USER=$(echo "$OLD_CONFIG" | jq -r .WP_USER_NAME)
if [ "$OLD_USER" != "$WP_USER_NAME" ]; then

    echo "Wordpress: update user (delete old and create new)"
    wp user create "$WP_USER_NAME" "$WP_USER_MAIL" \
        --user_pass="$WP_USER_PASS" \
        --role="author" \
        --allow-root || exit 1
    wp user delete "$OLD_USER" --yes --allow-root || true
else
    echo "Wordpress: update user info"
    wp user update "$WP_USER_NAME" \
        --user_email="$WP_USER_MAIL" \
        --user_pass="$WP_USER_PASS" \
        --role="author" \
        --allow-root || exit 1
fi

echo "Wordpress: update dabase done"