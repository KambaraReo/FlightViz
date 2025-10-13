#!/bin/bash

# k3s kubeconfig セットアップスクリプト

set -e

KUBECONFIG_PATH="/home/reo/k3s.yaml"
ORIGINAL_CONFIG="/etc/rancher/k3s/k3s.yaml"

echo "=== k3s kubeconfig セットアップ開始 ==="

# kubeconfigファイルが存在するかチェック
if [ ! -f "$ORIGINAL_CONFIG" ]; then
    echo "Error: $ORIGINAL_CONFIG が見つかりません。"
    echo "先に 'make setup-k3s' を実行してください。"
    exit 1
fi

# 外部アクセス用kubeconfigをコピー
echo "外部アクセス用kubeconfigを作成中..."
sudo cp "$ORIGINAL_CONFIG" "$KUBECONFIG_PATH"
sudo chown reo:reo "$KUBECONFIG_PATH"

# 現在のサーバー設定を表示
echo ""
echo "現在のサーバー設定:"
grep "server:" "$KUBECONFIG_PATH"

# VPSの外部IPアドレスを取得または設定
VPS_IP="${VPS_IP:-$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)}"

if [ -z "$VPS_IP" ] || [ "$VPS_IP" = "YOUR_VPS_IP_HERE" ]; then
    echo "VPS IPアドレスが設定されていません。"
    read -p "VPS IPアドレスを入力してください: " VPS_IP
fi

echo ""
echo "VPS IP: $VPS_IP"
echo ""
read -p "このIPでサーバー設定を更新しますか？ (Y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "設定更新をスキップしました。"
    echo "手動で $KUBECONFIG_PATH のサーバー設定を更新してください:"
    echo "  server: https://YOUR_VPS_IP:6443"
else
    # サーバーIPを外部IPに更新
    sed -i.bak "s|server: https://127.0.0.1:6443|server: https://$VPS_IP:6443|g" "$KUBECONFIG_PATH"
    echo "サーバー設定を更新しました:"
    grep "server:" "$KUBECONFIG_PATH"
fi

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "kubeconfigを使用するには以下を実行:"
echo "export KUBECONFIG=$KUBECONFIG_PATH"
echo ""
echo "または ~/.bashrc に追加:"
echo "echo 'export KUBECONFIG=$KUBECONFIG_PATH' >> ~/.bashrc"
echo ""
echo "接続テスト:"
echo "kubectl get nodes"
