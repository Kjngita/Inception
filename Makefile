NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

rebuild: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v

fclean: clean
	#remove project images
	@docker rmi -f mariadb wordpress nginx 2>/dev/null || true
	#remove build cache
	@docker builder prune -f

re: fclean up

.PHONY: all up down rebuild logs ps clean fclean re