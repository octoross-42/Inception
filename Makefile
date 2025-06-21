MAKEFLAGS += --no-print-directory

PROJECT_NAME=inception
DOCKER_COMPOSE_FILE="./srcs/docker-compose.yaml"

all : up

up :
	@"./srcs/tools/start.sh" && printf "\n"
	docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) up -d --remove-orphans
	$(MAKE) status

down :
# 	stop + rm
	@docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) down 

down-volume:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) down -v

stop :
	@docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) stop 

start :
	@docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) start 

clean :
	@docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(PROJECT_NAME) rm 

status :
	@docker ps

logs :
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) logs 

rev : down-volume
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build
	$(MAKE) up

re : down
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build
	$(MAKE) up

rec: down
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build --no-cache
	$(MAKE) up

recv: down-volume
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build --no-cache
	$(MAKE) up


mariadb: down
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build mariadb
	
mariadb-volume: down-volume
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build mariadb

wordpress: down
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build wordpress

wordpress-volume: down-volume
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build wordpress

nginx: down
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build nginx

nginx-volume: down-volume
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) build nginx
