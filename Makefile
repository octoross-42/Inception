MAKEFLAGS += --no-print-directory

PROJECT_NAME=inception
DOCKER_COMPOSE_FILE="./srcs/docker-compose.yaml"

all : up

start-docker:
	@sudo service docker start
	@sudo mkdir -p /home/octoross/data/database
	@sudo mkdir -p /home/octoross/data/state
	@sudo mkdir -p /home/octoross/data/wordpress-website
	@chmod +x srcs/tools/redirect-localhost.sh
	@chmod +x srcs/tools/start.sh

up : start-docker
	@"./srcs/tools/start.sh" && printf "\n"
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) up -d --remove-orphans
	@$(MAKE) status

down : start-docker
# 	stop + rm
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) down 

down-volume: start-docker
	@sudo rm -rf /home/octoross/data/database
	@sudo rm -rf /home/octoross/data/state
	@sudo rm -rf /home/octoross/data
	@sudo mkdir -p /home/octoross/data/database
	@sudo mkdir -p /home/octoross/data/state
	@sudo mkdir -p /home/octoross/data/wordpress-website
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) down -v

stop : start-docker
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) stop 

start : start-docker
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) start 

clean : start-docker
	@docker compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) rm 

status : start-docker
	@docker ps

logs : start-docker
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) logs 

rev : down-volume
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build
	@$(MAKE) up

re : down
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build
	@$(MAKE) up

rec: down
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build --no-cache
	@$(MAKE) up

recv: down-volume
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build --no-cache
	@$(MAKE) up


mariadb: down
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build mariadb
	
mariadb-volume: down-volume
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build mariadb

wordpress: down
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build wordpress

wordpress-volume: down-volume
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build wordpress

nginx: down
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build nginx

nginx-volume: down-volume
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build nginx

db-root:
	@docker exec -it mariadb_inception sh -c 'mysql -u root -p"$$DB_ROOT_PASS"'

db:
	@docker exec -it mariadb_inception sh -c 'mysql -u "$$DB_USER" -p"$$DB_PASS"'

# https://DOMAIN_NAME/wp-login.php

# @sudo usermod -aG docker $$(whoami)
# newgrp docker
