#!/bin/bash

# k3s nginx-ingress-controller セットアップスクリプト

set -e

echo "=== nginx-ingress-controller のセットアップ開始 ==="

# nginx-ingress-controller をインストール
echo "nginx-ingress-controller をインストール中..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# ingress-nginx の起動を待機
echo "ingress-nginx の起動を待機中..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "=== nginx-ingress-controller のセットアップ完了 ==="
echo ""
echo "Ingress Controller の状態を確認:"
echo "kubectl get pods -n ingress-nginx"
echo ""
echo "LoadBalancer サービスの外部IPを確認:"
echo "kubectl get service -n ingress-nginx ingress-nginx-controller"
