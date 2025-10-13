# Flight-Viz デプロイメント

このドキュメントでは、Kubernetes マニフェストを使用したデプロイ方法を説明します。

## ディレクトリ構造

```
k8s/
├── backend/
│   ├── deployment.yaml    # Backendアプリケーション
│   ├── service.yaml       # Backendサービス
│   ├── configmap.yaml     # 設定情報
│   └── secret.yaml        # 機密情報（DB接続、DockerHub）
├── frontend/
│   ├── deployment.yaml    # Frontendアプリケーション
│   └── service.yaml       # Frontendサービス
├── database/
│   ├── deployment.yaml    # PostgreSQLデータベース
│   ├── service.yaml       # データベースサービス
│   └── pvc.yaml          # 永続ボリューム
├── ingress.yaml          # 外部アクセス設定
└── namespace.yaml        # Namespace定義
```

## デプロイ方法

### 1. 自動デプロイ（推奨）

```bash
# デプロイスクリプトを実行
./deploy.sh
```

### 2. 手動デプロイ

```bash
# 1. Namespace作成
kubectl apply -f k8s/namespace.yaml

# 2. Secrets と ConfigMaps
kubectl apply -f k8s/backend/secret.yaml
kubectl apply -f k8s/backend/configmap.yaml

# 3. Database
kubectl apply -f k8s/database/pvc.yaml
kubectl apply -f k8s/database/deployment.yaml
kubectl apply -f k8s/database/service.yaml

# 4. Backend
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml

# 5. Frontend
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml

# 6. Ingress
kubectl apply -f k8s/ingress.yaml
```

### 3. Makefile を使用

```bash
# デプロイ
make deploy

# 状況確認
make status

# ログ確認
make logs-backend
make logs-frontend
make logs-database

# クリーンアップ
make clean
```

## 状況確認

```bash
# Pod状況
kubectl get pods -n flight-viz

# サービス状況
kubectl get svc -n flight-viz

# Ingress状況
kubectl get ingress -n flight-viz

# 詳細情報
kubectl describe pod <pod-name> -n flight-viz
```

## ログ確認

```bash
# Backend
kubectl logs -f deployment/backend -n flight-viz

# Frontend
kubectl logs -f deployment/frontend -n flight-viz

# Database
kubectl logs -f deployment/database -n flight-viz

# 初期化コンテナ（DB migration）
kubectl logs deployment/backend -c db-migrate -n flight-viz
```

## トラブルシューティング

### Pod が起動しない場合

```bash
# Pod の詳細確認
kubectl describe pod <pod-name> -n flight-viz

# イベント確認
kubectl get events -n flight-viz --sort-by='.lastTimestamp'

# ログ確認
kubectl logs <pod-name> -n flight-viz
```

### データベース接続エラー

```bash
# Database Pod の状況確認
kubectl get pods -l app=database -n flight-viz

# Database ログ確認
kubectl logs -f deployment/database -n flight-viz

# Database に直接接続
kubectl exec -it deployment/database -n flight-viz -- psql -U user -d flight_viz_production
```

### イメージプル エラー

```bash
# Secret 確認
kubectl get secret docker-registry-secret -n flight-viz -o yaml

# Pod の詳細確認（ImagePullBackOff の原因）
kubectl describe pod <pod-name> -n flight-viz
```

## 更新・再起動

```bash
# Backend 再起動
kubectl rollout restart deployment/backend -n flight-viz

# Frontend 再起動
kubectl rollout restart deployment/frontend -n flight-viz

# Database 再起動
kubectl rollout restart deployment/database -n flight-viz

# 新しいイメージでデプロイ
kubectl set image deployment/backend backend=sakuraore/flight-viz-backend:new-tag -n flight-viz
kubectl set image deployment/frontend frontend=sakuraore/flight-viz-frontend:new-tag -n flight-viz
```

## ローカルアクセス

```bash
# Port forwarding
kubectl port-forward -n flight-viz service/frontend-service 8080:80
kubectl port-forward -n flight-viz service/backend-service 3000:3000

# アクセス
# Frontend: http://localhost:8080
# Backend: http://localhost:3000
```

## クリーンアップ

```bash
# 完全削除
kubectl delete namespace flight-viz

# または
make clean
```

## 設定変更

### 環境変数の管理

**ローカル開発環境:**

- `.env.development` - Docker Compose 用の設定
- `frontend/.env.development` - フロントエンド用の設定

**本番環境（Kubernetes）:**

- `k8s/backend/configmap.yaml` - 非機密情報
- `k8s/backend/secret.yaml` - 機密情報（base64 エンコード必要）

### 本番環境の設定変更

**ConfigMap の変更:**

1. `k8s/backend/configmap.yaml` を編集
2. `kubectl apply -f k8s/backend/configmap.yaml`
3. `kubectl rollout restart deployment/backend -n flight-viz`

**Secret の変更:**

1. `k8s/backend/secret.yaml` を編集（平文で記述可能）
2. `kubectl apply -f k8s/backend/secret.yaml`
3. `kubectl rollout restart deployment/backend -n flight-viz`

**Secret の編集例:**

```yaml
# Backend設定
stringData:
  POSTGRES_PASSWORD: "new-password"
  SECRET_KEY_BASE: "new-secret-key"

# DockerHub認証情報
stringData:
  .dockerconfigjson: |
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "your-username",
          "password": "your-token"
        }
      }
    }
```

注意: `stringData`フィールドを使用することで、Kubernetes が自動的に base64 エンコードを行います。

### リソース制限の変更

1. `k8s/backend/deployment.yaml` または `k8s/frontend/deployment.yaml` を編集
2. `kubectl apply -f k8s/backend/deployment.yaml`

## セキュリティ

- 全てのコンテナは非 root ユーザーで実行
- 不要な権限は削除
- SSL/TLS 証明書は自動取得
- Secret は適切に管理
