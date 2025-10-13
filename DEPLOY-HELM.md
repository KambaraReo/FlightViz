# Flight-Viz Helm デプロイガイド

このドキュメントでは、Helm と SSL 証明書（cert-manager）を使用して Flight-Viz アプリケーションを VPS の k3s クラスターにデプロイする手順を説明します。

## 前提条件

- k3s がインストール済みの VPS
- kubectl が k3s クラスターに接続済み
- Docker がインストール済み
- Helm 3.x がインストール済み

## クイックスタート

### 開発環境（SSL 無し）

```bash
# 必要なコンポーネントをセットアップしてデプロイ
make dev

# データを投入
make import-data

# ローカルアクセス用ポートフォワード
make port-forward
```

アクセス先: http://localhost:8080

### 本番環境（SSL 有り）

**前提条件**: DNS 設定が必要

```bash
# DNS設定確認
make check-dns

# 必要なコンポーネントをセットアップしてデプロイ
make prod

# データを投入
make import-data
```

アクセス先: https://your-domain.com

## 詳細なデプロイ手順

### 1. リポジトリのクローン

```bash
git clone <your-repo-url>
cd flight-viz
```

### 2. 必要なコンポーネントのセットアップ

#### k3s クラスターのセットアップ（VPS 上で実行）

```bash
# k3sのインストール
make setup-k3s

# 外部アクセス用kubeconfig設定
make setup-kubeconfig
```

#### nginx-ingress-controller のセットアップ

```bash
make setup-ingress
# または
./setup-ingress.sh
```

#### cert-manager のセットアップ（SSL 証明書用）

```bash
make setup-cert-manager
# または
./setup-cert-manager.sh
```

### 3. アプリケーションのデプロイ

#### 開発環境へのデプロイ

```bash
# Makefileを使用
make deploy-dev

# または直接Helmコマンドを使用
helm upgrade --install flight-viz ./helm/flight-viz \
  --namespace flight-viz \
  --create-namespace \
  --values ./helm/flight-viz/values-dev.yaml \
  --wait
```

#### 本番環境へのデプロイ

```bash
# Makefileを使用（推奨）
make deploy-prod DOMAIN=your-domain.com EMAIL=your-email@example.com

# または直接Helmコマンドを使用
helm upgrade --install flight-viz ./helm/flight-viz \
  --namespace flight-viz \
  --create-namespace \
  --values ./helm/flight-viz/values-prod.yaml \
  --set ingress.hosts[0].host=your-domain.com \
  --set ingress.tls[0].hosts[0]=your-domain.com \
  --set certManager.issuer.email=your-email@example.com \
  --wait
```

### 4. データの投入

```bash
# CSVデータを投入
make import-data

# または直接実行
kubectl exec -it -n flight-viz deployment/flight-viz-backend -- bundle exec rails tracks:import_all_data
kubectl exec -it -n flight-viz deployment/flight-viz-backend -- bundle exec rails airports:import_file_data[jp-airport.csv]
```

## 設定のカスタマイズ

### values.yaml の編集

環境に応じて values.yaml を編集できます：

- `helm/flight-viz/values-dev.yaml` - 開発環境用
- `helm/flight-viz/values-prod.yaml` - 本番環境用
- `helm/flight-viz/values.yaml` - デフォルト設定

### 主要な設定項目

#### ドメイン設定

```yaml
ingress:
  hosts:
    - host: your-domain.com # 実際のドメインに変更
```

#### SSL 証明書設定

```yaml
certManager:
  issuer:
    email: your-email@example.com # Let's Encrypt用メールアドレス

ingress:
  tls:
    - secretName: flight-viz-tls
      hosts:
        - your-domain.com
```

#### リソース制限

```yaml
resources:
  backend:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
```

#### レプリカ数

```yaml
replicaCount:
  backend: 1
  frontend: 1
```

## 運用コマンド

### 状態確認

```bash
# デプロイ状態確認
make status

# ログ確認
make logs-backend
make logs-frontend

# Helmテスト実行
make test
```

### メンテナンス

```bash
# バックエンドPodにシェル接続
make shell-backend

# PostgreSQLに接続
make shell-db

# ポートフォワード（ローカルアクセス用）
make port-forward
```

### アップデート

```bash
# イメージを再ビルドしてデプロイ
make deploy-dev  # または deploy-prod

# 設定のみ更新
helm upgrade flight-viz ./helm/flight-viz \
  --namespace flight-viz \
  --values ./helm/flight-viz/values-prod.yaml
```

## SSL 証明書について

### Let's Encrypt 証明書の自動取得

cert-manager が自動的に Let's Encrypt 証明書を取得・更新します：

1. **ClusterIssuer**: Let's Encrypt との連携設定
2. **Certificate**: 証明書リソースの自動作成
3. **Secret**: 証明書の自動保存

### 証明書の状態確認

```bash
# 証明書の状態確認
kubectl get certificate -n flight-viz

# 証明書の詳細確認
kubectl describe certificate flight-viz-tls -n flight-viz

# cert-managerのログ確認
kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager
```

### トラブルシューティング

証明書が取得できない場合：

1. **DNS 設定確認**: ドメインが VPS の IP アドレスを指しているか
2. **Firewall 設定**: ポート 80, 443 が開いているか
3. **ClusterIssuer 確認**: `kubectl get clusterissuer`
4. **Challenge 確認**: `kubectl get challenge -n flight-viz`

## セキュリティ考慮事項

### 本番環境での推奨設定

1. **パスワード変更**:

   ```yaml
   postgresql:
     auth:
       password: "STRONG_PASSWORD_HERE"
   ```

2. **リソース制限**:

   ```yaml
   resources:
     limits:
       cpu: 1000m
       memory: 1Gi
   ```

3. **ネットワークポリシー**:

   ```bash
   # 必要に応じてネットワークポリシーを追加
   kubectl apply -f network-policies/
   ```

4. **定期バックアップ**:

   ```bash
   # PostgreSQLのバックアップスクリプトを設定
   kubectl create cronjob pg-backup --image=postgres:14 --schedule="0 2 * * *" -- pg_dump
   ```

## アンデプロイ

```bash
# アプリケーションの削除
make clean

# または
helm uninstall flight-viz --namespace flight-viz
kubectl delete namespace flight-viz
```

## トラブルシューティング

### よくある問題

1. **Pod が起動しない**:

   ```bash
   kubectl describe pod -n flight-viz
   kubectl logs -n flight-viz <pod-name>
   ```

2. **証明書が取得できない**:

   ```bash
   kubectl get certificate -n flight-viz
   kubectl describe certificate flight-viz-tls -n flight-viz
   ```

3. **データベース接続エラー**:

   ```bash
   kubectl logs -n flight-viz deployment/flight-viz-backend
   ```

### ログ確認

```bash
# 全体的な状態確認
kubectl get all -n flight-viz

# 特定のコンポーネントのログ
kubectl logs -n flight-viz -l app.kubernetes.io/component=backend
kubectl logs -n flight-viz -l app.kubernetes.io/component=frontend
kubectl logs -n flight-viz -l app.kubernetes.io/component=postgresql
```

## パフォーマンス最適化

### 本番環境での推奨設定

1. **リソース制限の調整**
2. **レプリカ数の増加**
3. **PostgreSQL のチューニング**
4. **CDN の使用検討**

詳細な設定は `helm/flight-viz/values-prod.yaml` を参照してください。
