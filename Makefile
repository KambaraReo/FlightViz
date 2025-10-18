# Flight-Viz Kubernetes Deployment

.PHONY: deploy status logs clean help

deploy: ## Deploy Flight-Viz to Kubernetes
	@echo "Deploying Flight-Viz..."
	./deploy.sh

status: ## Show deployment status
	@echo "Deployment Status:"
	kubectl get pods,svc,ingress -n flight-viz
	@echo ""
	@echo "Pod Details:"
	kubectl get pods -n flight-viz -o wide

logs-backend: ## Show backend logs
	kubectl logs -f deployment/backend -n flight-viz

logs-frontend: ## Show frontend logs
	kubectl logs -f deployment/frontend -n flight-viz

logs-database: ## Show database logs
	kubectl logs -f deployment/database -n flight-viz

shell-backend: ## Open shell in backend pod
	kubectl exec -it deployment/backend -n flight-viz -- bash

shell-database: ## Open PostgreSQL shell
	kubectl exec -it deployment/database -n flight-viz -- psql -U user -d flight_viz_production

port-forward: ## Port forward for local access
	@echo "Port forwarding..."
	@echo "Frontend: http://localhost:8080"
	@echo "Backend: http://localhost:3000"
	kubectl port-forward -n flight-viz service/frontend-service 8080:80 &
	kubectl port-forward -n flight-viz service/backend-service 3000:3000 &

clean: ## Clean up deployment
	@echo "Cleaning up..."
	kubectl delete namespace flight-viz --ignore-not-found=true
	@echo "Cleanup complete"

restart-backend: ## Restart backend deployment
	kubectl rollout restart deployment/backend -n flight-viz

restart-frontend: ## Restart frontend deployment
	kubectl rollout restart deployment/frontend -n flight-viz

restart-database: ## Restart database deployment
	kubectl rollout restart deployment/database -n flight-viz

events: ## Show recent events
	kubectl get events -n flight-viz --sort-by='.lastTimestamp'

describe-pods: ## Describe all pods
	kubectl describe pods -n flight-viz

help: ## Show this help
	@echo 'Flight-Viz Kubernetes Management'
	@echo ''
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
