NAME = inception

COMPOSE = docker compose -p $(NAME) -f srcs/docker-compose.yml

DATA_DIR = $(HOME)/data
WORDPRESS_DATA = $(DATA_DIR)/wordpress
MARIADB_DATA = $(DATA_DIR)/mariadb

all: up

up:
	mkdir -p $(WORDPRESS_DATA)
	mkdir -p $(MARIADB_DATA)
	$(COMPOSE) up --build -d

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down

fclean:
	$(COMPOSE) down -v --rmi all --remove-orphans
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up build down stop start restart logs ps clean fclean re
