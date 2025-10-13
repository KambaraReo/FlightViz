# 環境変数設定ガイド

## 環境変数管理方針

**重要**: すべての `.env` ファイルは GitHub にアップロードしません（`.gitignore`で除外）

### ファイル構成

```
プロジェクトルート/
├── .env.example                   # 統合テンプレート（GitHub管理）
├── .env                          # 共通設定（gitignore対象）
├── .env.development              # 開発環境設定（gitignore対象）
├── .env.production               # 本番環境設定（gitignore対象）
└── frontend/
    ├── .env.example              # フロントエンドテンプレート（GitHub管理）
    ├── .env                      # フロントエンド共通（gitignore対象）
    ├── .env.development          # フロントエンド開発（gitignore対象）
    └── .env.production           # フロントエンド本番（gitignore対象）
```

## セットアップ手順

### 初回セットアップ

```bash
# Makefileを使用した自動セットアップ（推奨）
make setup-env

# または手動セットアップ
cp .env.example .env
cp .env.example .env.development
cp .env.example .env.production
cp frontend/.env.example frontend/.env
cp frontend/.env.example frontend/.env.development
cp frontend/.env.example frontend/.env.production

# 実際の値を設定
vim .env.development      # 開発環境用の値を設定
vim .env.production       # 本番環境用の値を設定（VPS IP、パスワードなど）
vim frontend/.env.development
vim frontend/.env.production

# 環境変数の確認
make check-env
```

## 環境別設定内容

### 共通設定 `.env`

```bash
# アプリケーション情報
APP_NAME=Flight-Viz
APP_VERSION=1.0.0

# 共通データベース設定
POSTGRES_USER=user
```

### 開発環境 `.env.development`

```bash
# Rails 環境
RAILS_ENV=development

# PostgreSQL データベース設定
POSTGRES_PASSWORD=password
POSTGRES_DB=flight_viz_development

# ドメイン設定（開発環境）
DOMAIN=localhost
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3000
```

### 本番環境 `.env.production`

```bash
# Rails 環境
RAILS_ENV=production

# PostgreSQL データベース設定
POSTGRES_PASSWORD=CHANGE_THIS_TO_STRONG_PASSWORD
POSTGRES_DB=flight_viz_production

# ドメイン設定（本番環境）
DOMAIN=flightviz.reokambara.com
FRONTEND_URL=https://flightviz.reokambara.com
BACKEND_URL=https://flightviz.reokambara.com/api

# VPS設定
VPS_IP=YOUR_VPS_IP_HERE
K3S_SERVER=https://YOUR_VPS_IP_HERE:6443

# DockerHub設定（本番環境でのイメージ配布用）
DOCKER_REGISTRY=your-dockerhub-username
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password

# SSL設定
SSL_ENABLED=true
CERT_EMAIL=YOUR_EMAIL
```

## フロントエンド環境変数

### 共通設定 `frontend/.env`

```bash
VITE_API_BASE_URL=/api
VITE_APP_NAME=Flight-Viz
VITE_APP_VERSION=1.0.0
```

### 開発環境 `frontend/.env.development`

```bash
VITE_API_BASE_URL=/api
VITE_APP_ENV=development
VITE_DOMAIN=localhost:5173
```

### 本番環境 `frontend/.env.production`

```bash
VITE_API_BASE_URL=/api
VITE_APP_ENV=production
VITE_DOMAIN=flightviz.reokambara.com
```

## k3s 本番環境での Secrets 管理

### 質問への回答

`.env.production` の内容を k3s 上で Secrets として管理するかについて：

**Secrets で管理すべき項目:**

- `POSTGRES_PASSWORD` - データベースパスワード
- `SECRET_KEY_BASE` - Rails 秘密鍵（追加推奨）

**ConfigMap で管理可能な項目:**

- `DOMAIN` - ドメイン名（公開情報）
- `FRONTEND_URL` - フロントエンド URL（公開情報）
- `RAILS_ENV` - 環境名（公開情報）
- `POSTGRES_DB` - データベース名（公開情報）

**環境変数で管理する項目:**

- `VPS_IP` - デプロイ時に使用、k3s 内では不要
- `K3S_SERVER` - デプロイ時に使用、k3s 内では不要

### Kubernetes Secrets 作成例

```bash
# PostgreSQLパスワードをSecretで管理
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=your_strong_password \
  --namespace flight-viz

# Rails秘密鍵をSecretで管理（推奨）
kubectl create secret generic rails-secret \
  --from-literal=SECRET_KEY_BASE=$(openssl rand -hex 64) \
  --namespace flight-viz
```

### Helm テンプレートでの使用

```yaml
# Secret参照例
env:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: POSTGRES_PASSWORD
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: rails-secret
        key: SECRET_KEY_BASE
```

## 環境変数の読み込み順序

### Docker Compose（開発環境）

1. `.env` - 共通設定
2. `.env.development` - 開発環境設定（上書き）

### Vite（フロントエンド）

1. `frontend/.env` - 共通設定
2. `frontend/.env.development` または `frontend/.env.production` - 環境別設定

### Kubernetes（本番環境）

1. ConfigMap - 公開可能な設定
2. Secret - 機密情報
3. 環境変数 - デプロイ時設定

## セキュリティベストプラクティス

### 機密情報の分類

**Level 1 (Secret 必須):**

- データベースパスワード
- API キー
- 暗号化キー

**Level 2 (ConfigMap 可能):**

- ドメイン名
- 環境名
- 公開 URL

**Level 3 (環境変数可能):**

- デプロイ設定
- 開発用設定

### 定期的なローテーション

```bash
# パスワード更新例
kubectl patch secret postgres-secret \
  -p '{"data":{"POSTGRES_PASSWORD":"'$(echo -n "new_password" | base64)'"}}' \
  --namespace flight-viz

# Pod再起動で新しいパスワードを適用
kubectl rollout restart deployment/flight-viz-backend --namespace flight-viz
```

## トラブルシューティング

### 環境変数が反映されない場合

1. **ファイル存在確認**

   ```bash
   make check-env
   ```

2. **Docker Compose 再起動**

   ```bash
   docker compose down
   docker compose up -d
   ```

3. **Kubernetes 設定確認**

   ```bash
   kubectl get configmap -n flight-viz
   kubectl get secret -n flight-viz
   ```

### 設定値確認方法

```bash
# 開発環境
make test-env-dev
# Docker Compose環境
docker compose exec backend env | grep -E "(RAILS|POSTGRES|DOMAIN)"

# 本番環境
make test-env-prod
# Kubernetes環境
kubectl exec -it deployment/flight-viz-backend -n flight-viz -- env | grep -E "(RAILS|POSTGRES|DOMAIN)"
```
