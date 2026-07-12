COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/ahouass/data
MYSQL_DIR = $(DATA_DIR)/mariadb
WP_DIR = $(DATA_DIR)/wordpress

GREEN = \033[0;32m
RED = \033[0;31m
YELLOW = \033[0;33m
BLUE = \033[0;34m
RESET = \033[0m

all: up

dirs:
	@echo "$(BLUE)Creating directories...$(RESET)"
	mkdir -p $(MYSQL_DIR) $(WP_DIR)
	@echo "$(GREEN)✅ Directories created$(RESET)"

up: dirs
	@echo "$(BLUE)Starting Inception...$(RESET)"
	$(COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)✅ Inception is running! Access: https://ahouass.42.fr$(RESET)"

down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	$(COMPOSE) -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Containers stopped$(RESET)"

re: down dirs
	@echo "$(BLUE)Rebuilding...$(RESET)"
	$(COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)✅ Rebuild complete$(RESET)"

clean: down
	@echo "$(RED)Cleaning containers...$(RESET)"
	@echo "$(GREEN)✅ Clean complete$(RESET)"

fclean: down
	@echo "$(RED)Full clean...$(RESET)"
	$(COMPOSE) -f $(COMPOSE_FILE) down --rmi all -v --remove-orphans
	sudo rm -rf $(DATA_DIR)
	docker system prune -f
	@echo "$(GREEN)✅ Full clean complete$(RESET)"

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

ps:
	$(COMPOSE) -f $(COMPOSE_FILE) ps

.PHONY: all dirs up down re clean fclean logs ps