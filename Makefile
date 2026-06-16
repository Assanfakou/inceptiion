NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_PATH = /home/$(USER)/data

all:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@$(COMPOSE) up --build -d

up:
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

status:
	@$(COMPOSE) ps
clean:
	@$(COMPOSE) down -v
	@sudo rm -rf $(DATA_PATH)
restart: down up

fclean: clean
	@docker system prune -af

re: fclean all

logs:
	@$(COMPOSE) logs 

.PHONY: all up down clean fclean re logs status restart
