#!/usr/bin/env sh

# exit script as soon as a cmd has non-zero exit  
set -e

# creation des certificats ssl du site
/usr/local/bin/cert-gen.sh

sed "s|%%DOMAIN_NAME%%|$DOMAIN_NAME|g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "✅  Lancement de nginx..."
exec nginx -g 'daemon off;'
