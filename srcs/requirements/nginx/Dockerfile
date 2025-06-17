FROM debian:bullseye

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y nginx && \
    ufw allow 'Nginx HTTPs'

RUN mkdir -p /var/www/octoross.42/html