FROM debian:bullseye

# force debian a ne pas poser de questions dans tous les RUN apt
ENV DEBIAN_FRONTEND=noninteractive

# a titre indicatif -> pour la doc et les outils docker dinfos 
EXPOSE 9000

COPY tools/wp-config.sh	/usr/local/bin/wp-config.sh
COPY tools/init-db.sh	/usr/local/bin/init-db.sh
COPY tools/update-db.sh	/usr/local/bin/update-db.sh
COPY tools/wordpress-start.sh /usr/local/bin/wordpress-start.sh

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y php \
		php-cli \
		php-fpm \
		php-mysql \
		php-xml \
		php-mbstring \
		php-curl \
		php-gd \
		php-zip \
		curl && \
	# install Wordpress-CLI 
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
    # installation jq -> creer json et comparer valeurs
	apt-get install -y --no-install-recommends jq && \
	# install wait-for-it -> attendre que la database soit ready pour avancer
	curl -sSL https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    -o /usr/local/bin/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh && \
	# droits pour execution de mes scripts
	chmod +x /usr/local/bin/wp-config.sh /usr/local/bin/wordpress-start.sh /usr/local/bin/init-db.sh /usr/local/bin/update-db.sh && \
	apt clean && rm -rf /var/lib/apt/lists/*

    

# Installation fichiers du site (index.html, index.php, etc) grace a wordpress merci wordpress
WORKDIR /var/www/html
RUN wp core download --allow-root --locale=fr_FR && \
	chown -R www-data:www-data .
    


ENTRYPOINT ["/usr/local/bin/wordpress-start.sh"]
