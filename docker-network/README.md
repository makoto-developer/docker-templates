# Docker Network テンプレート

Dockerネットワークの様々な設定パターンを示すサンプルです。

## ネットワーク構成図

```
                    ┌─────────────────────────────────────────────────────────┐
                    │                      Internet                           │
                    └─────────────────────────────────────────────────────────┘
                                              │
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│  frontend-net (172.20.0.0/24)                                                   │
│  ┌─────────────┐                                                                │
│  │  frontend   │ :8080                                                          │
│  │  (nginx)    │                                                                │
│  └──────┬──────┘                                                                │
└─────────┼───────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│  backend-net (172.21.0.0/24)                                                    │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                         │
│  │  frontend   │───▶│    api      │───▶│   cache     │                         │
│  │  (nginx)    │    │  (node.js)  │    │  (redis)    │                         │
│  └─────────────┘    └──────┬──────┘    └─────────────┘                         │
└────────────────────────────┼────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│  db-net (172.22.0.0/24) [internal: true - 外部アクセス不可]                      │
│  ┌─────────────┐    ┌─────────────┐                                             │
│  │     db      │◀───│   adminer   │                                             │
│  │ (postgres)  │    │             │                                             │
│  └─────────────┘    └─────────────┘                                             │
└─────────────────────────────────────────────────────────────────────────────────┘
          ▲
          │
┌─────────┴───────────────────────────────────────────────────────────────────────┐
│  admin-net (172.23.0.0/24)                                                      │
│  ┌─────────────┐                                                                │
│  │   adminer   │ :8081                                                          │
│  └─────────────┘                                                                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## ネットワーク種別

| ネットワーク | サブネット | 用途 | internal |
|-------------|-----------|------|----------|
| frontend-net | 172.20.0.0/24 | 外部公開用 | false |
| backend-net | 172.21.0.0/24 | アプリ間通信 | false |
| db-net | 172.22.0.0/24 | DB専用 | **true** |
| admin-net | 172.23.0.0/24 | 管理ツール | false |

## 使い方

### 1. 環境設定

```bash
cp .env.example .env
# .env ファイルを編集してパスワード等を設定
```

### 2. 必要なディレクトリ作成

```bash
mkdir -p nginx/html nginx/conf.d init-db
echo "<h1>Hello Docker Network</h1>" > nginx/html/index.html
```

### 3. 起動

```bash
docker compose up -d
```

### 4. 確認

```bash
# ネットワーク一覧
docker network ls

# ネットワーク詳細
docker network inspect myapp_frontend
docker network inspect myapp_backend
docker network inspect myapp_database

# コンテナのネットワーク接続確認
docker inspect frontend --format='{{json .NetworkSettings.Networks}}' | jq
```

### 5. 接続テスト

```bash
# frontendからapiへの接続テスト
docker exec frontend ping -c 2 api

# apiからdbへの接続テスト
docker exec api ping -c 2 db

# apiからcacheへの接続テスト
docker exec api ping -c 2 cache

# monitoringから全サービスへの接続テスト
docker exec monitoring ping -c 2 frontend
docker exec monitoring ping -c 2 api
docker exec monitoring ping -c 2 db
docker exec monitoring ping -c 2 cache
```

## ネットワーク設定のポイント

### 1. internal: true

```yaml
db-net:
  internal: true  # 外部からのアクセスを完全にブロック
```

データベースなど外部公開が不要なサービス用。

### 2. aliases（ネットワークエイリアス）

```yaml
networks:
  backend-net:
    aliases:
      - api-server  # 別名でもアクセス可能
      - app
```

同一サービスに複数の名前でアクセス可能。

### 3. カスタムサブネット

```yaml
ipam:
  config:
    - subnet: "172.20.0.0/24"
      gateway: "172.20.0.1"
```

IPアドレス範囲を明示的に指定。

### 4. 複数ネットワーク接続

```yaml
services:
  frontend:
    networks:
      - frontend-net  # 外部公開用
      - backend-net   # 内部通信用
```

セキュリティ境界を分離しつつ必要な通信を許可。

## セキュリティのベストプラクティス

1. **最小権限の原則**: 必要なネットワークのみに接続
2. **内部ネットワーク**: DBは `internal: true` で外部遮断
3. **ネットワーク分離**: フロントエンド/バックエンド/DBを分離
4. **エイリアス活用**: サービス名を抽象化して依存関係を緩和

## 停止・削除

```bash
# 停止
docker compose down

# ボリュームも含めて削除
docker compose down -v

# ネットワークも含めて削除
docker compose down -v --remove-orphans
```

## 参考

- [Docker Network ドキュメント](https://docs.docker.com/network/)
- [Compose ネットワーク設定](https://docs.docker.com/compose/networking/)
