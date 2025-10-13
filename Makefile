# Flight-Viz Makefile

.PHONY: help setup-k3s setup-ingress setup-cert-manager build build-and-tag docker-login push-images pull-images import-images deploy-dev deploy-prod deploy-prod-local test clean check-env setup-env test-env-dev test-env-prod

# Load environment variables from .env files
# Note: Files are loaded in order, later files override earlier ones
ifneq (,$(wildcard .env))
    include .env
    export $(shell grep -v '^#' .env | grep -v '^$$' | sed 's/=.*//')
endif

ifneq (,$(wildcard .env.development))
    include .env.development
    export $(shell grep -v '^#' .env.development | grep -v '^$$' | sed 's/=.*//')
endif

ifneq (,$(wildcard .env.production))
    include .env.production
    export $(shell grep -v '^#' .env.production | grep -v '^$$' | sed 's/=.*//')
endif

# Variables with fallback defaults
NAMESPACE ?= flight-viz
RELEASE_NAME ?= flight-viz

# Use environment variables if available, otherwise use defaults
ifndef DOMAIN
    DOMAIN = flightviz.reokambara.com
endif

ifndef CERT_EMAIL
    EMAIL = $(CERT_EMAIL)
endif

ifndef VPS_IP
    VPS_IP = YOUR_VPS_IP_HERE
endif

ifndef KUBECONFIG
    KUBECONFIG = /home/reo/k3s.yaml
endif

# Export KUBECONFIG for all kubectl commands
export KUBECONFIG

help: ## Show this help message
	@echo 'Flight-Viz Deployment Makefile'
	@echo ''
	@echo 'Environments:'
	@echo '  - development: Local Docker Compose environment'
	@echo '  - production:  VPS k3s cluster environment'
	@echo ''
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-k3s: ## Setup k3s cluster (run on VPS)
	@echo "Setting up k3s..."
	curl -sfL https://get.k3s.io | sh -
	sudo chmod 644 /etc/rancher/k3s/k3s.yaml
	@echo "Copying kubeconfig with external IP..."
	sudo cp /etc/rancher/k3s/k3s.yaml /home/reo/k3s.yaml
	sudo chown reo:reo /home/reo/k3s.yaml
	@echo "Please update server IP in /home/reo/k3s.yaml to your VPS external IP"
	@echo "Then run: export KUBECONFIG=/home/reo/k3s.yaml"

setup-ingress: ## Setup nginx-ingress-controller
	@echo "Setting up nginx-ingress-controller..."
	./setup-ingress.sh

setup-kubeconfig: ## Setup kubeconfig for external access
	@echo "Setting up kubeconfig for external access..."
	./setup-kubeconfig.sh

create-kubeconfig: ## Create kubeconfig with VPS IP directly
	@echo "Creating kubeconfig with VPS IP $(VPS_IP)..."
	@if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then \
		echo "Error: /etc/rancher/k3s/k3s.yaml not found. Run 'make setup-k3s' first."; \
		exit 1; \
	fi
	sudo cp /etc/rancher/k3s/k3s.yaml /home/reo/k3s.yaml
	sudo chown reo:reo /home/reo/k3s.yaml
	sed -i.bak "s|server: https://127.0.0.1:6443|server: https://$(VPS_IP):6443|g" /home/reo/k3s.yaml
	@echo "kubeconfig created with server: https://$(VPS_IP):6443"
	@echo "Run: export KUBECONFIG=/home/reo/k3s.yaml"

setup-cert-manager: ## Setup cert-manager
	@echo "Setting up cert-manager..."
	./setup-cert-manager.sh

build: ## Build Docker images
	@echo "Building Docker images..."
	docker build -f backend/Dockerfile.prod -t flight-viz-backend:latest ./backend
	docker build -f frontend/Dockerfile.prod -t flight-viz-frontend:latest ./frontend

build-and-tag: build ## Build and tag images for DockerHub
	@echo "Tagging images for DockerHub..."
	@if [ -z "$(DOCKER_REGISTRY)" ]; then \
		echo "Error: DOCKER_REGISTRY not set. Please set it in .env.production"; \
		exit 1; \
	fi
	docker tag flight-viz-backend:latest $(DOCKER_REGISTRY)/flight-viz-backend:latest
	docker tag flight-viz-frontend:latest $(DOCKER_REGISTRY)/flight-viz-frontend:latest
	docker tag flight-viz-backend:latest $(DOCKER_REGISTRY)/flight-viz-backend:$(shell date +%Y%m%d-%H%M%S)
	docker tag flight-viz-frontend:latest $(DOCKER_REGISTRY)/flight-viz-frontend:$(shell date +%Y%m%d-%H%M%S)

docker-login: ## Login to DockerHub
	@echo "Logging in to DockerHub..."
	@if [ -z "$(DOCKER_USERNAME)" ] || [ -z "$(DOCKER_PASSWORD)" ]; then \
		echo "Error: DOCKER_USERNAME or DOCKER_PASSWORD not set"; \
		exit 1; \
	fi
	@echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin

push-images: build-and-tag docker-login ## Push images to DockerHub
	@echo "Pushing images to DockerHub..."
	docker push $(DOCKER_REGISTRY)/flight-viz-backend:latest
	docker push $(DOCKER_REGISTRY)/flight-viz-frontend:latest
	docker push $(DOCKER_REGISTRY)/flight-viz-backend:$(shell date +%Y%m%d-%H%M%S)
	docker push $(DOCKER_REGISTRY)/flight-viz-frontend:$(shell date +%Y%m%d-%H%M%S)

import-images: build ## Import Docker images to k3s (local method)
	@echo "Importing images to k3s..."
	sudo k3s ctr images import <(docker save flight-viz-backend:latest)
	sudo k3s ctr images import <(docker save flight-viz-frontend:latest)

pull-images: ## Pull images from DockerHub to k3s
	@echo "Pulling images from DockerHub to k3s..."
	@if [ -z "$(DOCKER_REGISTRY)" ]; then \
		echo "Error: DOCKER_REGISTRY not set. Please set it in .env.production"; \
		exit 1; \
	fi
	sudo k3s crictl pull $(DOCKER_REGISTRY)/flight-viz-backend:latest
	sudo k3s crictl pull $(DOCKER_REGISTRY)/flight-viz-frontend:latest

deploy-dev: import-images ## Deploy to development environment (uses .env.development)
	@echo "Deploying to development environment..."
	@if [ ! -f .env.development ]; then \
		echo "Error: .env.development not found. Run 'make setup-env' first"; \
		exit 1; \
	fi
	$(eval include .env.development)
	helm upgrade --install $(RELEASE_NAME) ./helm/flight-viz \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--values ./helm/flight-viz/values-dev.yaml \
		--set postgresql.auth.password=$(POSTGRES_PASSWORD) \
		--wait \
		--timeout 10m

deploy-prod-local: import-images ## Deploy to production with local images
	@echo "Deploying to production environment with local images..."
	@if [ ! -f .env.production ]; then \
		echo "Error: .env.production not found. Run 'make setup-env' first"; \
		exit 1; \
	fi
	$(eval include .env.production)
	@echo "Domain: $(DOMAIN)"
	@echo "Email: $(CERT_EMAIL)"
	@echo "VPS IP: $(VPS_IP)"
	helm upgrade --install $(RELEASE_NAME) ./helm/flight-viz \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--values ./helm/flight-viz/values-prod.yaml \
		--set ingress.hosts[0].host=$(DOMAIN) \
		--set ingress.tls[0].hosts[0]=$(DOMAIN) \
		--set certManager.issuer.email=$(CERT_EMAIL) \
		--set registry.enabled=false \
		--set postgresql.auth.password=$(POSTGRES_PASSWORD) \
		--wait \
		--timeout 15m

deploy-prod: push-images ## Deploy to production environment with DockerHub images
	@echo "Deploying to production environment with DockerHub images..."
	@if [ ! -f .env.production ]; then \
		echo "Error: .env.production not found. Run 'make setup-env' first"; \
		exit 1; \
	fi
	$(eval include .env.production)
	@echo "Domain: $(DOMAIN)"
	@echo "Email: $(CERT_EMAIL)"
	@echo "Registry: $(DOCKER_REGISTRY)"
	helm upgrade --install $(RELEASE_NAME) ./helm/flight-viz \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--values ./helm/flight-viz/values-prod.yaml \
		--set ingress.hosts[0].host=$(DOMAIN) \
		--set ingress.tls[0].hosts[0]=$(DOMAIN) \
		--set certManager.issuer.email=$(CERT_EMAIL) \
		--set image.backend.repository=$(DOCKER_REGISTRY)/flight-viz-backend \
		--set image.frontend.repository=$(DOCKER_REGISTRY)/flight-viz-frontend \
		--set registry.enabled=true \
		--set registry.username=$(DOCKER_USERNAME) \
		--set registry.password=$(DOCKER_PASSWORD) \
		--set postgresql.auth.password=$(POSTGRES_PASSWORD) \
		--wait \
		--timeout 15m

test: ## Run Helm tests
	@echo "Running Helm tests..."
	helm test $(RELEASE_NAME) --namespace $(NAMESPACE)

status: ## Show deployment status
	@echo "Deployment status:"
	kubectl get pods,svc,ingress -n $(NAMESPACE)
	@echo ""
	@echo "Certificate status:"
	kubectl get certificate -n $(NAMESPACE) || echo "No certificates found"

logs-backend: ## Show backend logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=backend --tail=100 -f

logs-frontend: ## Show frontend logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=frontend --tail=100 -f

import-data: ## Import flight data
	@echo "Importing flight data..."
	kubectl exec -it -n $(NAMESPACE) deployment/$(RELEASE_NAME)-backend -- bundle exec rails tracks:import_all_data

shell-backend: ## Open shell in backend pod
	kubectl exec -it -n $(NAMESPACE) deployment/$(RELEASE_NAME)-backend -- bash

shell-db: ## Open PostgreSQL shell
	kubectl exec -it -n $(NAMESPACE) deployment/$(RELEASE_NAME)-postgresql -- psql -U user -d flight_viz_production

port-forward: ## Port forward services for local access
	@echo "Port forwarding services..."
	@echo "Frontend: http://localhost:8080"
	@echo "Backend: http://localhost:3000"
	kubectl port-forward -n $(NAMESPACE) service/$(RELEASE_NAME)-frontend 8080:80 &
	kubectl port-forward -n $(NAMESPACE) service/$(RELEASE_NAME)-backend 3000:3000 &

clean: ## Clean up deployment
	@echo "Cleaning up deployment..."
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE) || true
	kubectl delete namespace $(NAMESPACE) || true

validate: ## Validate Helm chart
	@echo "Validating Helm chart..."
	helm lint ./helm/flight-viz
	helm template $(RELEASE_NAME) ./helm/flight-viz --values ./helm/flight-viz/values-dev.yaml > /dev/null
	@echo "Chart validation passed!"

check-dns: ## Check DNS configuration
	@echo "Checking DNS configuration for $(DOMAIN)..."
	@echo "Expected IP: $(VPS_IP)"
	@echo "Actual IP:"
	@nslookup $(DOMAIN) || dig +short $(DOMAIN) || echo "DNS lookup failed"
	@echo ""
	@echo "If DNS is not configured, add this A record:"
	@echo "$(DOMAIN) -> $(VPS_IP)"

check-env: ## Check environment variables and files
	@echo "=== Flight-Viz Environment Status ==="
	@echo ""
	@echo "Current Environment Variables:"
	@echo "  NAMESPACE: $(NAMESPACE)"
	@echo "  RELEASE_NAME: $(RELEASE_NAME)"
	@echo "  DOMAIN: $(DOMAIN)"
	@echo "  EMAIL: $(EMAIL)"
	@echo "  VPS_IP: $(VPS_IP)"
	@echo "  KUBECONFIG: $(KUBECONFIG)"
	@echo ""
	@echo "Backend Environment Files:"
	@echo -n "  .env: "; [ -f .env ] && echo "✓ exists" || echo "✗ missing (optional)"
	@echo -n "  .env.development: "; [ -f .env.development ] && echo "✓ exists" || echo "✗ missing (required for dev)"
	@echo -n "  .env.production: "; [ -f .env.production ] && echo "✓ exists" || echo "✗ missing (required for prod)"
	@echo ""
	@echo "Frontend Environment Files:"
	@echo -n "  frontend/.env: "; [ -f frontend/.env ] && echo "✓ exists" || echo "✗ missing (optional)"
	@echo -n "  frontend/.env.development: "; [ -f frontend/.env.development ] && echo "✓ exists" || echo "✗ missing (required for dev)"
	@echo -n "  frontend/.env.production: "; [ -f frontend/.env.production ] && echo "✓ exists" || echo "✗ missing (required for prod)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'make setup-env' to create missing files from templates"
	@echo "  2. Edit .env.development and .env.production with actual values"
	@echo "  3. Run 'make test-env-dev' or 'make test-env-prod' to verify"

setup-env: ## Setup environment files from templates
	@echo "Setting up environment files from .env.example template..."
	@if [ ! -f .env ]; then \
		cp .env.example .env && echo "Created .env from template"; \
	else \
		echo ".env already exists"; \
	fi
	@if [ ! -f .env.development ]; then \
		cp .env.example .env.development && echo "Created .env.development from template"; \
	else \
		echo ".env.development already exists"; \
	fi
	@if [ ! -f .env.production ]; then \
		cp .env.example .env.production && echo "Created .env.production from template"; \
	else \
		echo ".env.production already exists"; \
	fi
	@if [ ! -f frontend/.env ]; then \
		cp frontend/.env.example frontend/.env && echo "Created frontend/.env from template"; \
	else \
		echo "frontend/.env already exists"; \
	fi
	@if [ ! -f frontend/.env.development ]; then \
		cp frontend/.env.example frontend/.env.development && echo "Created frontend/.env.development from template"; \
	else \
		echo "frontend/.env.development already exists"; \
	fi
	@if [ ! -f frontend/.env.production ]; then \
		cp frontend/.env.example frontend/.env.production && echo "Created frontend/.env.production from template"; \
	else \
		echo "frontend/.env.production already exists"; \
	fi
	@echo ""
	@echo "Environment files created from templates"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit .env.development with development values"
	@echo "  2. Edit .env.production with production values (VPS IP, passwords, etc.)"
	@echo "  3. Edit frontend/.env.development and frontend/.env.production"
	@echo "  4. Run 'make check-env' to verify setup"

test-env-dev: ## Test environment variables for development
	@echo "=== Testing Development Environment ==="
	@if [ ! -f .env.development ]; then \
		echo "Error: .env.development not found"; \
		exit 1; \
	fi
	$(eval include .env.development)
	@echo "DOMAIN: $(DOMAIN)"
	@echo "VPS_IP: $(VPS_IP)"
	@echo "POSTGRES_PASSWORD: $(if $(POSTGRES_PASSWORD),***SET***,NOT SET)"

test-env-prod: ## Test environment variables for production
	@echo "=== Testing Production Environment ==="
	@if [ ! -f .env.production ]; then \
		echo "Error: .env.production not found"; \
		exit 1; \
	fi
	$(eval include .env.production)
	@echo "DOMAIN: $(DOMAIN)"
	@echo "VPS_IP: $(VPS_IP)"
	@echo "CERT_EMAIL: $(CERT_EMAIL)"
	@echo "POSTGRES_PASSWORD: $(if $(POSTGRES_PASSWORD),***SET***,NOT SET)"
	@echo ""
	@echo "DockerHub Settings:"
	@echo "DOCKER_REGISTRY: $(DOCKER_REGISTRY)"
	@echo "DOCKER_USERNAME: $(DOCKER_USERNAME)"
	@echo "DOCKER_PASSWORD: $(if $(DOCKER_PASSWORD),***SET***,NOT SET)"

# Development shortcuts
dev: setup-ingress deploy-dev ## Quick development setup (local images)
prod: setup-ingress setup-cert-manager deploy-prod ## Quick production setup (DockerHub images)
prod-local: setup-ingress setup-cert-manager deploy-prod-local ## Quick production setup (local images)
