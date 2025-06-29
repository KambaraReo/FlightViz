# Flight-Viz — 航跡可視化アプリ

## 概要
**Flight-Viz** は、航空機の飛行経路を可視化・アニメーション表示する Web アプリケーションです。
地図上に航跡を表示し、再生・停止・速度変更などの機能を備え、飛行の様子を直感的に確認できます。


## このアプリでできること
- 特定のフライトの飛行経路（航跡）表示とアニメーション表示
- アニメーションの一時停止・再開・リセット操作
- アニメーションの再生速度設定
- スライダーによる手動再生位置の変更
- 高度に応じた航跡の色分け表示


## 画面構成
- **アニメーション操作描画領域**
  - アニメーションの一時停止・再開・リセット
  - アニメーションの再生速度変更
  - アニメーションの再生位置変更
  - モード変更（通常表示/アニメーション表示）

- **地図描画領域**
  - 航跡の通常表示/アニメーション表示
  - 時刻表示（JST/UTC）
  - 空港マーカー表示
  - 高度による色分け

- **設定パネル描画領域**
  - 日付選択
  - 便選択
  - 高度表示のON/OFF

### レスポンシブ画面
※ 画像ファイル追加予定

## デモ
※ GIFファイル追加予定

## 環境・主な使用技術
### 環境
- macOS Sonoma 14.5

### フロントエンド
- Node.js 18.20.8
- npm 10.8.2
- TypeScript
- React 19.1.0
- Vite 6.3.5
- Tailwind CSS
- Leaflet.js
- React Router

### バックエンド
- ruby 3.2.8
- Ruby on Rails 7.2.2.1
- PostgreSQL 14.18
- FactoryBot + RSpec

### インフラ
- Docker（開発環境構築）


## ディレクトリ構成
```plaintext
flight-viz/
├── backend/                # Rails API（tracks, flights エンドポイントなど）
│   ├── app/
│   ├── db/
│   ├── lib/data/           # 取り込み対象のCSVファイル配置ディレクトリ
│   ├── spec/
│   └── ...
├── frontend/               # React アプリケーション（Leafletでの可視化）
│   ├── src/
│   │   ├── components/     # 共通UI部品（Map, Selectorなど）
│   │   ├── pages/          # 各画面（Map画面など）
│   │   └── utils/          # APIユーティリティなど
│   └── ...
├── docker-compose.yml      # Dockerコンテナ設定
└── README.md
```


## CSVデータについて
### 読み込むCSVファイル
本アプリでは、飛行データをCSV形式で取り込み、Railsでデータベースに保存する必要があります。

### データ取り込みのヒント
`backend/lib/data/` 配下に各CSVデータを格納した後、以下のrakeタスクでインポート可能です。

```bash
# 飛行データの取り込み
# Import all CSV files under lib/data recursively
docker compose exec backend bundle exec rails tracks:import_all_data

# Import all CSV files under the specified directory in lib/data
ex) docker compose exec backend bundle exec rails tracks:import_dir_data[201904]

# Import specified CSV file under lib/data
ex) docker compose exec backend bundle exec rails tracks:import_file_data[201904/track20190422.csv]

# 空港データの取り込み
# Import Airports CSV file under lib/data
docker compose exec backend bundle exec rails airports:import_file_data[jp-airport.csv]
```

### 必須カラム
#### 飛行データCSVのフォーマット
| カラム名       | 説明                             | 型                |
|----------------|----------------------------------|-------------------|
| `flight_id`    | フライトの識別子                 | string            |
| `timestamp`    | データ記録時刻（UTC）            | datetime (ISO8601)|
| `lat`          | 緯度                             | float             |
| `lon`          | 経度                             | float             |
| `alt`     | 高度（フィート）                 | integer           |
| `aircraft_type`     | 型式                 | string           |

> ※ `timestamp` は ISO8601 形式 (`2019-04-22T00:00:00.000Z`) で記載されている必要があります。

#### 空港データCSVのフォーマット
| カラム名       | 説明                             | 型                |
|----------------|----------------------------------|-------------------|
| `country_code`    | 国コード                 | string            |
| `icao_code`    | ICAO空港コード            | string|
| `label`          | 空港名                             | string             |
| `lat`          | 緯度                             | float             |
| `lon`     | 経度                 | integer           |　float
| `uri`          | データソースのURI                             | string             |
| `status`          | 地図上への表示有無（0 or 1）                             | integer             |


## ローカル環境起動手順
```bash
# プロジェクトのルートディレクトリに移動

# Docker コンテナをビルド＆起動
docker compose build
docker compose up -d

# データベースのセットアップ
docker compose exec backend bundle exec rails db:create db:migrate

# フロントエンドの依存パッケージをインストール
docker compose exec frontend npm install

# Rails API のRSpecテストを実行（任意）
docker compose exec backend bundle exec rspec
```

## 備考
本番化未対応のため、ローカル環境で動作をお試しください。
