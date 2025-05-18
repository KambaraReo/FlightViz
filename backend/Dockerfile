FROM ruby:3.2

# 必要なライブラリのインストール
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs

# 作業ディレクトリを指定
WORKDIR /app

# Gemfile 関連を先にコピー
COPY Gemfile* ./

# bundle install
RUN bundle install

# 残りのコードをコピー
COPY . .

# Entrypoint スクリプトをコピーし実行権限をつける
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Entrypoint を指定
ENTRYPOINT ["entrypoint.sh"]

# CMD で実行するメインプロセス（Entrypoint から呼ばれる）
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]

