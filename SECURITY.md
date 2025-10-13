# セキュリティガイド

## 機密情報の管理

### GitHub に公開しない情報

- **VPS IP アドレス**: 攻撃対象の特定リスク
- **データベースパスワード**: 不正アクセスリスク
- **API キー**: サービス悪用リスク
- **SSL 証明書の秘密鍵**: 通信傍受リスク
- **Rails 秘密鍵**: セッション改ざんリスク

### 安全な管理方法

#### 1. 環境変数ファイルの管理

**すべての `.env` ファイルは GitHub にアップロードしません**

```bash
# Makefileを使用した自動セットアップ
make setup-env

# または手動でテンプレートから作成
cp .env.example .env
cp .env.example .env.development
cp .env.example .env.production
cp frontend/.env.example frontend/.env
cp frontend/.env.example frontend/.env.development
cp frontend/.env.example frontend/.env.production

# 本番環境用の機密情報を設定
vim .env.production
# VPS_IP=YOUR_ACTUAL_IP
# POSTGRES_PASSWORD=STRONG_PASSWORD
# CERT_EMAIL=your-email@domain.com
```

#### 2. k3s 本番環境での Secrets 管理

**機密情報は Kubernetes シークレットで管理:**

```bash
# PostgreSQLパスワード
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=STRONG_PASSWORD \
  --namespace flight-viz

# Rails秘密鍵（推奨）
kubectl create secret generic rails-secret \
  --from-literal=SECRET_KEY_BASE=$(openssl rand -hex 64) \
  --namespace flight-viz
```

**公開情報は ConfigMap で管理:**

```bash
# ドメイン名など公開可能な設定
kubectl create configmap app-config \
  --from-literal=DOMAIN=flightviz.reokambara.com \
  --from-literal=RAILS_ENV=production \
  --namespace flight-viz
```

#### 3. 環境変数の分類

**Secret 必須 (機密情報):**

- `POSTGRES_PASSWORD` - データベースパスワード
- `SECRET_KEY_BASE` - Rails 秘密鍵
- API キー類

**ConfigMap 可能 (公開情報):**

- `DOMAIN` - ドメイン名
- `RAILS_ENV` - 環境名
- `POSTGRES_DB` - データベース名
- `FRONTEND_URL` - フロントエンド URL

**デプロイ時のみ使用:**

- `VPS_IP` - kubeconfig 設定用
- `K3S_SERVER` - kubeconfig 設定用

## Kubernetes セキュリティ設定

### Pod Security Context

```yaml
# values.yaml
security:
  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000

  securityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: false
    runAsNonRoot: true
    runAsUser: 1000
    capabilities:
      drop:
        - ALL
```

### Network Policy

```bash
# ネットワークポリシーを有効化
helm upgrade flight-viz ./helm/flight-viz \
  --set security.networkPolicy.enabled=true
```

### セキュリティヘッダー

Ingress で以下のセキュリティヘッダーを自動設定：

- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Content-Security-Policy
- Referrer-Policy

## VPS セキュリティ対策

### 基本設定

```bash
# SSH設定強化
sudo vim /etc/ssh/sshd_config
# PasswordAuthentication no
# PermitRootLogin no
# Port 2222 (デフォルトポート変更)

# ファイアウォール設定
sudo ufw enable
sudo ufw allow 2222/tcp  # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 6443/tcp  # k3s API (必要な場合のみ)

# 自動更新有効化
sudo apt update && sudo apt upgrade -y
sudo apt install unattended-upgrades
```

### k3s セキュリティ

```bash
# k3s API サーバーへの外部アクセス制限
sudo ufw deny 6443/tcp

# 内部ネットワークからのみアクセス許可
sudo ufw allow from 10.0.0.0/8 to any port 6443
```

## 監視・ログ

### 不正アクセス監視

```bash
# 失敗したSSH接続を監視
sudo tail -f /var/log/auth.log | grep "Failed password"

# k3s ログ監視
sudo journalctl -u k3s -f
```

### アラート設定

```bash
# fail2ban でブルートフォース攻撃を防御
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

## 環境変数セキュリティ

### ファイル権限設定

```bash
# 環境変数ファイルの権限を制限
chmod 600 .env*
chmod 600 frontend/.env*

# 所有者のみ読み書き可能に設定
chown $USER:$USER .env*
chown $USER:$USER frontend/.env*
```

### 機密情報のローテーション

```bash
# PostgreSQLパスワード更新
kubectl patch secret postgres-secret \
  -p '{"data":{"POSTGRES_PASSWORD":"'$(echo -n "new_password" | base64)'"}}' \
  --namespace flight-viz

# Pod再起動で新しいパスワードを適用
kubectl rollout restart deployment/flight-viz-backend --namespace flight-viz

# Rails秘密鍵更新
kubectl patch secret rails-secret \
  -p '{"data":{"SECRET_KEY_BASE":"'$(openssl rand -hex 64 | base64 -w 0)'"}}' \
  --namespace flight-viz
```

## インシデント対応

### 不正アクセスが疑われる場合

1. **即座にアクセス遮断**

   ```bash
   sudo ufw deny from SUSPICIOUS_IP
   ```

2. **パスワード変更**

   ```bash
   # データベースパスワード変更
   kubectl patch secret postgres-secret -p '{"data":{"POSTGRES_PASSWORD":"NEW_BASE64_PASSWORD"}}'
   ```

3. **ログ確認**

   ```bash
   # アクセスログ確認
   sudo grep "SUSPICIOUS_IP" /var/log/nginx/access.log
   ```

### 環境変数漏洩時の対応

1. **即座にパスワード変更**
2. **関連するすべてのシークレット更新**
3. **アクセスログの詳細確認**
4. **影響範囲の特定**

## 定期的なセキュリティチェック

### 月次チェックリスト

- [ ] システムアップデート実行
- [ ] 不要なポートが開いていないか確認
- [ ] ログに異常なアクセスがないか確認
- [ ] SSL 証明書の有効期限確認
- [ ] バックアップの動作確認
- [ ] 環境変数ファイルの権限確認
- [ ] Kubernetes シークレットの確認

### セキュリティスキャン

```bash
# ポートスキャン（内部から）
nmap localhost

# 脆弱性チェック
sudo apt install lynis
sudo lynis audit system

# 環境変数ファイルの権限確認
ls -la .env*
ls -la frontend/.env*
```

## バックアップとリカバリ

### 重要データのバックアップ

```bash
# PostgreSQLデータベースバックアップ
kubectl exec -it deployment/flight-viz-postgresql -n flight-viz -- \
  pg_dump -U user flight_viz_production > backup_$(date +%Y%m%d).sql

# Kubernetesシークレットバックアップ
kubectl get secret postgres-secret -n flight-viz -o yaml > postgres-secret-backup.yaml
kubectl get secret rails-secret -n flight-viz -o yaml > rails-secret-backup.yaml
```

### 環境変数ファイルのバックアップ

```bash
# 暗号化してバックアップ
tar czf env-backup-$(date +%Y%m%d).tar.gz .env*
gpg --symmetric --cipher-algo AES256 env-backup-$(date +%Y%m%d).tar.gz
rm env-backup-$(date +%Y%m%d).tar.gz
```
