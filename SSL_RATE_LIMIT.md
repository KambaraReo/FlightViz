# SSL証明書レート制限対応

Let's Encrypt のレート制限により、以下の変更を一時的に適用しています。
SSL証明書が正常に取得できるようになったら、これらの変更を元に戻してください。

## 戻すべき変更

### 1. backend/config/environments/production.rb

```ruby
# 現在（一時的）
config.force_ssl = false

# 戻すべき設定
config.force_ssl = true
config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
```

### 2. k8s/ingress.yaml

```yaml
# 現在（一時的）
annotations:
  # 一時的にHTTPのみ（SSL証明書のレート制限のため）
  # traefik.ingress.kubernetes.io/redirect-entry-point: https
  # traefik.ingress.kubernetes.io/router.tls: "true"
  # cert-manager.io/cluster-issuer: "letsencrypt-prod"

# 一時的にTLS設定をコメントアウト
# tls:
#   - hosts:
#       - flightviz.reokambara.com
#     secretName: flight-viz-tls

# 戻すべき設定
annotations:
  traefik.ingress.kubernetes.io/redirect-entry-point: https
  traefik.ingress.kubernetes.io/router.tls: "true"
  cert-manager.io/cluster-issuer: "letsencrypt-prod"

tls:
  - hosts:
      - flightviz.reokambara.com
    secretName: flight-viz-tls
```

## SSL 証明書復旧手順

1. Let's Encrypt レート制限解除確認

    ```bash
    $ kubectl get certificate -n flight-viz
    $ kubectl describe certificate flight-viz-tls -n flight-viz

    # Conditions に以下のようなエラーが出ていれば、レート制限中です。
    Type: Ready
    Status: False
    Reason: Failed
    Message: obtaining certificate: acme: Error -> One or more domains had a problem: ...
    urn:ietf:params:acme:error:rateLimited: Error creating new order :: too many certificates already issued for ...
    ```

2. 上記の一時的なレート制限設定を元に戻す

3. Kubernetes に適用

    ```bash
    $ kubectl apply -f k8s/ingress.yaml
    $ kubectl rollout restart deployment/backend -n flight-viz
    ```

4. 証明書発行確認

    ```bash
    $ kubectl get certificate -n flight-viz
    $ kubectl describe certificate flight-viz-tls -n flight-viz
    ```

## アクセス方法

- HTTP: http://flightviz.reokambara.com
- HTTPS: https://flightviz.reokambara.com（証明書レート制限の場合、利用不可）
