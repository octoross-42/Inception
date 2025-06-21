FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

COPY tools/init-db.sh /usr/local/bin/init-db.sh
COPY tools/mariadb-start.sh /usr/local/bin/mariadb-start.sh

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/local/bin/init-db.sh /usr/local/bin/mariadb-start.sh 


EXPOSE $DB_PORT

# Lancement de MariaDB avec script d'init
ENTRYPOINT ["/usr/local/bin/mariadb-start.sh"]
