# Docker Compose 設定ルール

> docker-compose.yml 作成時の詳細ガイドライン

## サービス定義の順序

docker-compose.yml 内のサービス定義は以下の順序で記述：

```yaml
services:
  service_name:
    # 1. イメージまたはビルド
    image: postgres:18-alpine
    # または
    build: ./path/to/dockerfile

    # 2. 再起動ポリシー
    restart: unless-stopped

    # 3. コンテナ名とホスト名
    container_name: ${SERVER_NAME}
    hostname: docker_${SERVER_NAME}

    # 4. 環境変数
    environment:
      KEY: value

    # 5. ポートマッピング
    ports:
      - "${PORT}:5432"

    # 6. ボリューム
    volumes:
      - data:/var/lib/data
      - ./config:/etc/config:ro

    # 7. 共有メモリ（該当する場合）
    shm_size: 256mb

    # 8. ネットワーク
    networks:
      - backend

    # 9. 依存関係
    depends_on:
      - db

    # 10. ヘルスチェック
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

    # 11. リソース制限
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

    # 12. ログ設定
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## イメージ選択のベストプラクティス

### Alpine版を優先

```yaml
# ✅ 推奨: Alpine版（軽量）
image: postgres:18-alpine
image: node:20-alpine
image: python:3.12-alpine

# ❌ 避ける: full版（サイズが大きい）
image: postgres:18
image: node:20
```

### 例外: Alpine版が存在しない場合

一部のイメージ（Elasticsearch、Jira等）はAlpine版が提供されていないため、公式イメージをそのまま使用。

## 再起動ポリシー

すべてのサービスに以下を設定：

```yaml
restart: unless-stopped
```

これにより、手動停止以外のすべてのケースで自動再起動。

## ヘルスチェック（必須）

すべてのサービスにヘルスチェックを設定：

```yaml
healthcheck:
  test: ["CMD-SHELL", "適切なコマンド"]
  interval: 10s       # チェック間隔
  timeout: 5s         # タイムアウト
  retries: 5          # リトライ回数
  start_period: 30s   # 起動猶予期間
```

### データベース別のヘルスチェック例

```yaml
# PostgreSQL
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB_NAME}"]

# MySQL
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]

# Redis
healthcheck:
  test: ["CMD", "redis-cli", "ping"]

# Elasticsearch
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
```

## リソース制限（推奨）

本番環境を想定したリソース制限を設定：

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'          # 最大CPU使用率
      memory: 2G           # 最大メモリ
    reservations:
      cpus: '0.5'          # 保証CPU
      memory: 512M         # 保証メモリ
```

## ログローテーション（推奨）

ディスク使用量を抑えるためログローテーション設定：

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"    # 1ファイルの最大サイズ
    max-file: "3"      # 保持するファイル数
```

## ボリュームの種類

### 1. Named Volume（データ永続化）

```yaml
volumes:
  # Docker管理のボリューム（推奨）
  - postgres_data:/var/lib/postgresql/data

# ボリューム定義
volumes:
  postgres_data:
    driver: local
```

### 2. Bind Mount（設定ファイル）

```yaml
volumes:
  # ホストのファイルをマウント（読み取り専用推奨）
  - ./config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
  - ./init:/docker-entrypoint-initdb.d:ro
```

### 3. tmpfs（一時ファイル）

```yaml
volumes:
  # メモリ上の一時ファイルシステム
  - postgres_tmp:/tmp
  - postgres_run:/var/run/postgresql

# ボリューム定義
volumes:
  postgres_tmp:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
  postgres_run:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
```

## ネットワーク設定

### カスタムブリッジネットワーク

```yaml
networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
          gateway: 172.28.0.1
```

### 複数ネットワーク接続

```yaml
services:
  api:
    networks:
      - frontend    # 外部公開用
      - backend     # 内部通信用

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # 外部アクセス遮断
```

## 環境変数の参照

すべての設定値は `.env` ファイルから参照：

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB_NAME}
  TZ: ${TZ}

ports:
  - "${POSTGRES_PORT}:5432"
```

## サービス依存関係

依存するサービスがある場合は `depends_on` を設定：

```yaml
services:
  api:
    depends_on:
      db:
        condition: service_healthy  # ヘルスチェックが成功するまで待機
      cache:
        condition: service_started  # 起動するまで待機
```

## コメントの記述

設定の意図を明確にするためコメントを追加：

```yaml
# Database data (persistent, Docker-managed named volume)
- postgres_data:/var/lib/postgresql/data

# Initialization scripts (read-only)
- ./init:/docker-entrypoint-initdb.d:ro

# Temporary files (tmpfs for performance)
- postgres_tmp:/tmp
```

## 検証チェックリスト

docker-compose.yml 作成後、以下を確認：

- [ ] Alpine版イメージを使用（可能な場合）
- [ ] `restart: unless-stopped` を設定
- [ ] ヘルスチェックを設定
- [ ] リソース制限を設定
- [ ] ログローテーションを設定
- [ ] すべての設定値が環境変数から参照
- [ ] ボリュームの用途が明確（data, config, tmp）
- [ ] 適切なコメントを記載
- [ ] `docker compose up -d` で起動確認
- [ ] `docker compose ps` でヘルスチェック確認
