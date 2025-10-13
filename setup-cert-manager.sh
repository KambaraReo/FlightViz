#!/bin/bash

# cert-manager セットアップスクリプト

set -e

echo "=== cert-manager のセットアップ開始 ==="

# cert-manager の名前空間を作成
echo "cert-manager 名前空間を作成中..."
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

# cert-manager CRDs をインストール
echo "cert-manager CRDs をインストール中..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

# cert-manager をインストール
echo "cert-manager をインストール中..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

# cert-manager の起動を待機
echo "cert-manager の起動を待機中..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cainjector -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=webhook -n cert-manager --timeout=300s

echo "=== cert-manager のセットアップ完了 ==="
echo ""
echo "cert-manager の状態を確認:"
echo "kubectl get pods -n cert-manager"
echo ""
echo "ClusterIssuer の確認:"
echo "kubectl get clusterissuer"
