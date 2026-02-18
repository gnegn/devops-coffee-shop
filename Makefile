APP_NAME = devops-coffee-shop
HELM_RELEASE_NAME = coffee-shop
NAMESPACE = default
MONITORING_NAMESPACE = monitoring
DOCKER_IMAGE = $(APP_NAME):latest
DOCKER_DIR = app/
SHELL := /bin/bash

YELLOW := $(shell tput setaf 3)
GREEN  := $(shell tput setaf 2)
RESET  := $(shell tput sgr0)

.PHONY: all build load deploy status test-traffic port-forward-app port-forward-grafana clean

all: build load deploy status

build:
	@echo "$(YELLOW)Building Docker image...$(RESET)"
	docker build -t $(DOCKER_IMAGE) $(DOCKER_DIR)
# Docker build

load:
	@echo "$(YELLOW)Loading image into Minikube...$(RESET)"
	minikube image load $(DOCKER_IMAGE)
# Push Docker image to Minikube 

deploy:
	@echo "$(YELLOW)Deploying Helm chart...$(RESET)"
	helm upgrade --install $(HELM_RELEASE_NAME) ./k8s
# Deploy Docker image

status:
	@echo "$(GREEN)Checking status...$(RESET)"
	kubectl get pods
	kubectl get svc
	kubectl get ingress
# Check status


port-forward-app:
	@echo "$(YELLOW)Port-forwarding App to http://localhost:8080...$(RESET)"
	kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
# App port-forwarding (Run in separate terminal)

port-forward-grafana:
	@echo "$(YELLOW)Port-forwarding Grafana to http://localhost:3000...$(RESET)"
	kubectl port-forward -n $(MONITORING_NAMESPACE) svc/monitor-grafana 3000:80
# Graphana port forwarding (Run in separate terminal)

test-traffic:
	@echo "$(GREEN)Generating random coffee orders...$(RESET)"
	@for i in {1..20}; do \
		types=("latte" "espresso" "cappuccino" "americano"); \
		type=$${types[$$RANDOM % 4]}; \
		echo "Ordering $$type..."; \
		curl -s -H "Host: coffeeshop.local" http://localhost:8080/order/$$type; \
		echo ""; \
		sleep 0.5; \
	done
	@echo "$(GREEN)Traffic generation complete!$(RESET)"
# Do multiple requests

clean:
	@echo "$(YELLOW)Uninstalling Helm release...$(RESET)"
	helm uninstall $(HELM_RELEASE_NAME)
# Delete Helm release