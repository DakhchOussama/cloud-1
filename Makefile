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
	@if [ -d "${HOME}/Desktop/data" ]; then \
		echo "Cleaning data directory..."; \
		docker run --rm -v ${HOME}/Desktop/data:/data alpine sh -c "rm -rf /data/*"; \
		rmdir ${HOME}/Desktop/data/my_mariadb ${HOME}/Desktop/data/my_wordpress 2>/dev/null || true; \
		rmdir ${HOME}/Desktop/data 2>/dev/null || true; \
		echo "Data directory cleaned."; \
	fi

fclean: clean
	@docker system prune -af
	@docker volume prune -f

re: fclean build

logs:
	docker compose -f ./src/inception/docker-compose.yml logs -f

ps:
	docker compose -f ./src/inception/docker-compose.yml ps

.PHONY: all build up down clean fclean re logs ps