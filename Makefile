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

re: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v

fclean: clean
	@docker system prune -af
	@docker volume prune -f

re: fclean up

.PHONY: all up down re logs ps clean fclean re