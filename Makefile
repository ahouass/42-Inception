LOGIN      = ahouass
DATA_DIR   = /home/$(LOGIN)/data
WP_DIR     = $(DATA_DIR)/wordpress
DB_DIR     = $(DATA_DIR)/mariadb

COMPOSE = docker-compose -f srcs/docker-compose.yml

all: up

dirs:
	mkdir -p $(WP_DIR)
	mkdir -p $(DB_DIR)

build: dirs
	$(COMPOSE) build

up: dirs
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	docker system prune -af

fclean: down
	docker system prune -af --volumes
	sudo rm -rf $(DATA_DIR)

re: fclean up

.PHONY: all dirs build up down stop start logs ps clean fclean re