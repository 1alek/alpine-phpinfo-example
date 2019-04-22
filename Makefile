include .env
export
VERSION=$(shell git rev-list --count HEAD)

CR=\033[0;91m
CG=\033[0;92m
CY=\033[0;93m
CB=\033[0;94m
CP=\033[0;95m
CC=\033[0;96m
CW=\033[0;97m
C0=\033[00m

all: help

commit: ## Commit changes to git
	@printf "${CG}>>>>>>>>>>>>>> COMMITING CHANGES >>>>>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	git add -A .
	git commit -m "commit-$(VERSION)"
	git push origin master
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

validate:
	@printf "${CG}>>>>>>>>>>>>>> VALIDATING COMPOSE CONFIG >>>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	docker-compose config
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

build: validate ## Build docker images
	@printf "${CG}>>>>>>>>>>>>>> BUILDING DOCKER IMAGE >>>>>>>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	docker-compose build --no-cache --force-rm
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

push: ## Push built docker image to registry
	@printf "${CG}>>>>>>>>>>>>>> PUSHING IMAGES TO REGISTRY >>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	docker-compose push
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

pull: ## Pull docker image from registry
	@printf "${CG}>>>>>>>>>>>>>> PULLING IMAGE FROM REGISTRY >>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	docker-compose pull
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

clean: ## Stop and Delete all containers and images
	@printf "${CG}>> Stopping running containers...${C0} \n"
	@docker ps | awk '/$(PROJECT)/ {print $$1}' | xargs -r docker stop
	@printf "${CG}>> Deleting containers...${C0} \n"
	@docker ps -a | awk '/$(PROJECT)/ {print $$1}' | xargs -r docker rm -f
	@printf "${CG}>> Deleting images...${C0} \n"
	@docker images | awk '/$(PROJECT)/ {print $$3}'| xargs -r docker rmi -f
	@printf "${CG}>> Done.${C0} \n"

install: pull uninstall ## Install and start Application
	@printf "${CG}>>>>>>>>>>>>>> STARTING UP APPLICATION >>>>>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	docker-compose up -d
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

uninstall: ## Stop and uninstall Application
	docker-compose down --remove-orphans -v --rmi all

deploy: ## Start Docker Swarm Stack
	docker stack deploy -c docker-compose.yml $(PROJECT)

logs: ## Tail logs from running container
	docker logs -f $(PROJECT)

shell:
	docker exec -ti $(PROJECT) bash

test: env ## Run tests
	@printf "${CG}>>>>>>>>>>>>>> START TESTS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${C0} \n"
	@printf "Waiting 5 seconds for docker container to start"; for i in {1..5}; do echo -n .; sleep 1; done; echo
	for test in $(shell ls tests); do bash tests/$$test || exit 1; done
	@printf "${CG}<<<<<<<<<<<<<< DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${C0} \n"

env: ## Show environment variables
	@env

version: ## Show version
	@echo ${VERSION}

help: ## Show this help
	@printf "${CW}NAME${C0}\n      ${CC}$(PROJECT)${C0}\n\n"
	@printf "${CW}DESCRIPTION${C0}\n      ${CC}$(DESCRIPTION)${C0}\n\n"
	@printf "${CW}VERSION${C0}\n      ${CC}${VERSION}${C0}\n\n${CW}OPTIONS${C0}\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "      ${CC}%-20s${C0} %s\n", $$1, $$2}'

.SILENT: ;
.PHONY: all
.SHELLFLAGS = -c
.ONESHELL: ;
.NOTPARALLEL: ;