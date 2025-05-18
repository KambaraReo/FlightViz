FROM node:18

# 作業ディレクトリを指定
WORKDIR /app

# package.json 関連を先にコピー
COPY package.json package-lock.json* yarn.lock* ./

# 依存をインストール
RUN npm install

# 残りのコードをコピー
COPY . .

# ポート5173を開放
EXPOSE 5173
