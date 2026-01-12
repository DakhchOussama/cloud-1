all: build

build:
	@mkdir -p ${HOME}/Desktop/data/my_mariadb
	@mkdir -p ${HOME}/Desktop/data/my_wordpress
	docker compose -f ./src/inception/docker-compose.yml up --build -d

up:
	docker compose -f ./src/inception/docker-compose.yml up -d

down:
	docker compose -f ./src/inception/docker-compose.yml down

clean: down
	@docker volume rm src_my_mariadb src_my_wordpress 2>/dev/null || true
	@rm -rf ${HOME}/Desktop/data

fclean: clean
	@docker system prune -af
	@docker volume prune -f

re: fclean build

logs:
	docker compose -f ./src/inception/docker-compose.yml logs -f

ps:
	docker compose -f ./src/inception/docker-compose.yml ps

.PHONY: all build up down clean fclean re logs ps