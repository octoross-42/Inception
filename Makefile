MAKEFLAGS += --no-print-directory


# TODO refaire les commandes ca fait pas ce que je veux -> make reconstruit les images si modif
all : up

up :
	@"./srcs/start.sh" && printf "\n" && $(MAKE) status

down :
# 	stop + rm
	@docker-compose -f "./srcs/docker-compose.yaml" -p inception down 

down-volume:
	@docker-compose -f "./srcs/docker-compose.yaml" -p inception down -v

stop :
	@docker-compose -f "./srcs/docker-compose.yaml" -p inception stop 

start :
	@docker-compose -f "./srcs/docker-compose.yaml" -p inception start 

clean :
	@docker-compose -f "./srcs/docker-compose.yaml" -p inception rm 

status :
	@docker ps

logs :
	@docker-compose -p inception -f "./srcs/docker-compose.yaml" logs 

re : down-volume
	@docker-compose -p inception -f "./srcs/docker-compose.yaml" build --no-cache
	$(MAKE) up