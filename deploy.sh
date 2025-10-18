#!/bin/bash

# Flight-Viz デプロイスクリプト

set -e

echo "Flight-Viz をデプロイしています..."

# Namespaceを作成（存在しない場合のみ）
echo "Namespaceを確認中..."
kubectl apply -f k8s/namespace.yaml

# 1. Secrets and ConfigMaps
echo "Secrets と ConfigMaps を適用中..."
kubectl apply -f k8s/backend/secret.yaml
kubectl apply -f k8s/backend/configmap.yaml

# 2. Database (PVC -> Deployment -> Service)
echo "Database を適用中..."
kubectl apply -f k8s/database/pvc.yaml
kubectl apply -f k8s/database/deployment.yaml
kubectl apply -f k8s/database/service.yaml

echo "Databaseの起動を待機中..."
kubectl wait --for=condition=ready pod -l app=database -n flight-viz --timeout=300s

# 3. Backend (Deployment -> Service)
echo "Backend を適用中..."
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml

# 4. Frontend (Deployment -> Service)
echo "Frontend を適用中..."
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml

# 5. Ingress
echo "Ingress を適用中..."
kubectl apply -f k8s/ingress.yaml

echo "デプロイメントの完了を待機中..."
kubectl wait --for=condition=available deployment/backend -n flight-viz --timeout=600s
kubectl wait --for=condition=available deployment/frontend -n flight-viz --timeout=300s

echo ""
echo "デプロイ完了！"
echo ""
echo "デプロイメント状況:"
kubectl get pods,svc,ingress -n flight-viz

echo ""
echo "アクセス情報:"
echo "  URL: https://flightviz.reokambara.com"
echo ""
echo "ログ確認コマンド:"
echo "  Backend:   kubectl logs -f deployment/backend -n flight-viz"
echo "  Frontend:  kubectl logs -f deployment/frontend -n flight-viz"
echo "  Database:  kubectl logs -f deployment/database -n flight-viz"
echo ""
echo "トラブルシューティング:"
echo "  Pod状況:   kubectl get pods -n flight-viz"
echo "  詳細情報:  kubectl describe pod <pod-name> -n flight-viz"
echo "  Events:    kubectl get events -n flight-viz --sort-by='.lastTimestamp'"
