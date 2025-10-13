#!/bin/bash

# Flight-Viz Helm デプロイスクリプト

set -e

# 設定変数
NAMESPACE="flight-viz"
RELEASE_NAME="flight-viz"
DOMAIN="${DOMAIN:-flightviz.reokambara.com}"
EMAIL="${EMAIL:-reo.k.dev@gmail.com}"

echo "=== Flight-Viz Helm デプロイ開始 ==="
echo "ドメイン: $DOMAIN"
echo "メールアドレス: $EMAIL"
echo ""

# Docker イメージをビルド
echo "Docker イメージをビルド中..."
docker build -f backend/Dockerfile.prod -t flight-viz-backend:latest ./backend
docker build -f frontend/Dockerfile.prod -t flight-viz-frontend:latest ./frontend

# k3s にイメージをインポート（ローカルレジストリを使用しない場合）
echo "k3s にイメージをインポート中..."
sudo k3s ctr images import <(docker save flight-viz-backend:latest)
sudo k3s ctr images import <(docker save flight-viz-frontend:latest)

# 名前空間を作成
echo "名前空間を作成中..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# values.yaml を環境変数で更新
echo "values.yaml を更新中..."
cp helm/flight-viz/values.yaml helm/flight-viz/values.yaml.bak

# ドメインとメールアドレスを更新
sed -i.tmp "s/flight-viz\.example\.com/$DOMAIN/g" helm/flight-viz/values.yaml
sed -i.tmp "s/your-email@example\.com/$EMAIL/g" helm/flight-viz/values.yaml
rm helm/flight-viz/values.yaml.tmp

# Helm でデプロイ
echo "Helm でデプロイ中..."
helm upgrade --install $RELEASE_NAME ./helm/flight-viz \
  --namespace $NAMESPACE \
  --create-namespace \
  --wait \
  --timeout 10m

# values.yaml を元に戻す
mv helm/flight-viz/values.yaml.bak helm/flight-viz/values.yaml

echo "=== デプロイ完了 ==="
echo ""
echo "アプリケーションの状態を確認:"
echo "kubectl get pods -n $NAMESPACE"
echo ""
echo "Ingress の状態を確認:"
echo "kubectl get ingress -n $NAMESPACE"
echo ""
echo "証明書の状態を確認:"
echo "kubectl get certificate -n $NAMESPACE"
echo ""
echo "アプリケーションにアクセス:"
echo "https://$DOMAIN"
echo ""
# echo "データ投入コマンド:"
# echo "kubectl exec -it -n $NAMESPACE deployment/flight-viz-backend -- bundle exec rails tracks:import_all_data"
