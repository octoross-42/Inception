FROM debian:bullseye

# force debian a ne pas poser de questions dans tous les RUN apt
ENV DEBIAN_FRONTEND=noninteractive

COPY tools/cert-gen.sh /usr/local/bin/cert-gen.sh
COPY conf/nginx.conf /etc/nginx/nginx.conf.template
COPY tools/nginx-start.sh /usr/local/bin/nginx-start.sh
# COPY test/index.html /var/www/html

RUN apt update -y && \
    apt upgrade -y && \
    apt install --no-install-recommends -y nginx \
		openssl \
    	apt-utils \
    	gettext && \
	chmod +x /usr/local/bin/cert-gen.sh /usr/local/bin/nginx-start.sh && \
	# cleaning
	apt clean && \
	rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/nginx-start.sh"]