# ─────────── Variables ───────────────────────────────────────────────
IMAGE_NAME=devops-coffee-shop
IMAGE_TAG=latest
MONITOR_RELEASE=monitor
APP_RELEASE=coffee-shop
NAMESPACE_MONITOR=monitoring
LOKI_RELEASE=loki
# ────────────────────────────────────────────────────────────────────
.PHONY: all setup-minikube build-image deploy-monitor deploy-logs deploy-app tunnel clean status deploy-logs

# ─────────── Launch local Kubernetes cluster with Minikube ──────────
start: setup-minikube build-image deploy-monitor deploy-logs deploy-app status
	@echo "\n\033[1;32m──────────────────────────────────────────────────────\033[0m"
	@echo "\033[1;36mLaunch\033[0m \033[1m'make tunnel'\033[0m \033[1;36min separate terminal\033[0m"
	@echo "\033[1;36mCoffee Shop:\033[0m \033[4mhttp://localhost/\033[0m"
	@echo "\033[1;36mGrafana:\033[0m \033[4mhttp://localhost/grafana/\033[0m \033[90m(admin/admin123)\033[0m"
	@echo "\033[1;32m──────────────────────────────────────────────────────\033[0m\n"

# ─────────── Setup Minikube ──────────────────────────────────────────
setup-minikube:
	minikube start
	minikube addons enable ingress
	minikube addons enable metrics-server

# ─────────── Preparing Docker Image ──────────────────────────────────
build-image:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) ./app/ || (echo "\n\033[91mERROR: Build failed. Possible credentials issue? Try:\033[0m\n"; \
		echo "1. Edit \033[1m~/.docker/config.json\033[0m"; \
		echo "2. Change \033[1m\"credsStore\": \"desktop.exe\"\033[0m to \033[1m\"credsStore\": \"\"\033[0m"; \
		echo "3. Save the file and try again.\n"; \
		exit 1)
	minikube image load $(IMAGE_NAME):$(IMAGE_TAG)

# ─────────── Grafana & Prometheus ────────────────────────────────── 
deploy-monitor:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade --install $(MONITOR_RELEASE) prometheus-community/kube-prometheus-stack \
		--namespace $(NAMESPACE_MONITOR) \
		--create-namespace \
		--set grafana."grafana\.ini".server.root_url="http://localhost/grafana/" \
		--set grafana."grafana\.ini".server.serve_from_sub_path=true \
		--set grafana.adminPassword=admin123 \
		--set grafana.additionalDataSources[0].name=Loki \
		--set grafana.additionalDataSources[0].type=loki \
		--set grafana.additionalDataSources[0].url=http://loki:3100 \
		--set grafana.additionalDataSources[0].access=proxy \
		--set grafana.additionalDataSources[0].jsonData.httpHeaderName1=X-Scope-OrgID \
		--set grafana.additionalDataSources[0].secureJsonData.httpHeaderValue1=1 \
		--wait
# ─────────── Loki ────────────────────────────────── 
deploy-logs:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm upgrade --install $(LOKI_RELEASE) grafana/loki-stack \
		--namespace $(NAMESPACE_MONITOR) \
		--set loki.persistence.enabled=true \
		--set loki.persistence.size=5Gi \
		--wait
	@echo "Loki встановлено. Тепер логи автоматично летять у Grafana."

# ─────────── Deploy Coffee Shop with Helm ─────────────────────────────
deploy-app:
	helm upgrade --install $(APP_RELEASE) ./k8s --wait

# ─────────── Launch Tunnel ────────────────────────────────────────────
tunnel:
	@echo "\n\033[1;32m──────────────────────────────────────────────────────\033[0m"
	@echo "\033[1;36mTunnel is starting...\033[0m \033[1;33mDon't close this window\033[0m"
	@echo "\033[1;32m──────────────────────────────────────────────────────\033[0m\n"
	minikube tunnel

# ─────────── Status Check  ────────────────────────────────────────────
status:
	kubectl get pods -A
	kubectl get ingress

# ─────────── Clean Up  ────────────────────────────────────────────────
clean:
	helm uninstall $(APP_RELEASE) || true
	helm uninstall $(MONITOR_RELEASE) -n $(NAMESPACE_MONITOR) || true
	minikube delete
	@echo "\n\033[1;32m──────────────────────────────────────────────────────\033[0m"
	@echo "\033[1;32mCleanup completed successfully\033[0m"
	@echo "\033[1;36mAll resources have been removed\033[0m"
	@echo "\033[1;32m──────────────────────────────────────────────────────\033[0m\n"

# ─────────── Simulation  ────────────────────────────────────────────────
load-test:
	@echo "Generating coffee orders..."
	@while true; do \
		curl -s "http://localhost/order/latte"; \
		curl -s "http://localhost/order/espresso"; \
	done
