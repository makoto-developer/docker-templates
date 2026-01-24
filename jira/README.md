# Jira Docker Setup

Atlassian Jira Software の Docker 構成

## 前提条件

- Docker & Docker Compose
- 最低 4GB RAM (推奨: 8GB以上)
- ポート 22400 (Jira), 22401 (PostgreSQL) が利用可能

## クイックスタート

### 1. 環境変数の設定

```bash
cp .env.example .env
```

`.env` ファイルを編集して、データベースの認証情報を設定:

```env
POSTGRES_USER=jira
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=jiradb
```

### 2. コンテナの起動

```bash
docker compose up -d
```

### 3. Jira のセットアップ

1. ブラウザで `http://localhost:22400` にアクセス
2. セットアップウィザードに従って設定
3. データベース接続設定:
   - Database Type: PostgreSQL
   - Hostname: jira_postgres
   - Port: 5432 (コンテナ内部ポート)
   - Database: jiradb
   - Username: (POSTGRES_USERで設定した値)
   - Password: (POSTGRES_PASSWORDで設定した値)

## ディレクトリ構造

```
jira/
├── docker-compose.yml  # Docker Compose 設定
├── .env.example        # 環境変数テンプレート
├── .gitignore          # Git 無視ファイル設定
├── init/               # PostgreSQL 初期化スクリプト
│   └── 01-jira-db-config.sql
└── README.md           # このファイル
```

## コマンド

### コンテナ管理

```bash
# 起動
docker compose up -d

# 停止
docker compose down

# ログ確認
docker compose logs -f jira
docker compose logs -f jira_postgres

# コンテナ状態確認
docker compose ps
```

### データベース接続

```bash
# PostgreSQL に接続
docker compose exec jira_postgres psql -U jira -d jiradb
```

## リバースプロキシ設定

Nginx 等のリバースプロキシを使用する場合は、`.env` で以下を設定:

```env
ATL_PROXY_NAME=jira.example.com
ATL_PROXY_PORT=443
ATL_TOMCAT_SCHEME=https
ATL_TOMCAT_SECURE=true
```

## バックアップ

### データベースバックアップ

```bash
docker compose exec jira_postgres pg_dump -U jira jiradb > backup_$(date +%Y%m%d).sql
```

### Jira データバックアップ

```bash
docker run --rm -v jira-server_jira_data:/data -v $(pwd):/backup alpine tar cvzf /backup/jira_data_$(date +%Y%m%d).tar.gz /data
```

## トラブルシューティング

### Jira が起動しない

1. PostgreSQL のヘルスチェック確認:
   ```bash
   docker compose ps
   ```

2. ログ確認:
   ```bash
   docker compose logs jira
   ```

3. メモリ不足の場合は `.env` で JVM メモリを調整:
   ```env
   JVM_MINIMUM_MEMORY=2048m
   JVM_MAXIMUM_MEMORY=4096m
   ```

### データベース接続エラー

1. PostgreSQL コンテナが起動しているか確認
2. 認証情報が正しいか確認
3. ネットワーク接続を確認:
   ```bash
   docker compose exec jira ping jira_postgres
   ```

## 参考リンク

- [Atlassian Jira Docker Hub](https://hub.docker.com/r/atlassian/jira-software)
- [Jira Documentation](https://confluence.atlassian.com/jirasoftware)
- [Jira Supported Platforms](https://confluence.atlassian.com/jirasoftware/supported-platforms-776733702.html)
