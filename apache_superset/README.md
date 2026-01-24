# Apache Superset Docker Setup

Apache Superset のDocker構成

## 前提条件

- Docker & Docker Compose
- 最低 4GB RAM (推奨: 8GB以上)
- ポート 22410 (Superset), 22411 (PostgreSQL), 22412 (Redis) が利用可能

## クイックスタート

### 1. 環境変数の設定

```bash
cp .env.example .env
```

`.env` ファイルを編集して、シークレットキーとデータベースの認証情報を設定:

```env
SUPERSET_SECRET_KEY=your_secure_secret_key
SUPERSET_ADMIN_PASSWORD=your_secure_password
POSTGRES_PASSWORD=your_secure_password
```

シークレットキーの生成:

```bash
openssl rand -base64 42
```

### 2. ディレクトリの作成

```bash
mkdir -p logs/superset logs/postgres config init
```

### 3. 初期設定ファイルの作成

config/superset_config.py が存在しない場合は作成:

```bash
touch config/superset_config.py
```

### 4. 初期セットアップ

初回のみ、initプロファイルを使用してデータベースとAdmin ユーザーを作成:

```bash
docker compose --profile init up superset_init
```

### 5. コンテナの起動

```bash
docker compose up -d
```

### 6. Superset にアクセス

ブラウザで `http://localhost:22410` にアクセス

ログイン情報:
- Username: admin (または .env で設定した SUPERSET_ADMIN_USERNAME)
- Password: .env で設定した SUPERSET_ADMIN_PASSWORD

## ディレクトリ構造

```
apache_superset/
├── docker-compose.yml    # Docker Compose 設定
├── .env.example          # 環境変数テンプレート
├── .gitignore            # Git 無視ファイル設定
├── config/               # Superset 設定ファイル
│   └── superset_config.py
├── init/                 # PostgreSQL 初期化スクリプト
├── logs/                 # ログファイル
│   ├── superset/
│   └── postgres/
└── README.md             # このファイル
```

## サービス構成

| サービス | 説明 | ポート |
|---------|------|--------|
| superset | メインWebアプリケーション | 22410 |
| superset_worker | Celeryワーカー（非同期タスク） | - |
| superset_beat | Celeryスケジューラ | - |
| superset_postgres | メタデータDB | 22411 |
| superset_redis | キャッシュ/Celeryブローカー | 22412 |

## コマンド

### コンテナ管理

```bash
# 起動
docker compose up -d

# 停止
docker compose down

# ログ確認
docker compose logs -f superset
docker compose logs -f superset_worker
docker compose logs -f superset_postgres

# コンテナ状態確認
docker compose ps
```

### Superset CLI

```bash
# コンテナ内でSupersetコマンドを実行
docker compose exec superset superset --help

# データベースマイグレーション
docker compose exec superset superset db upgrade

# 新しいAdminユーザーを作成
docker compose exec superset superset fab create-admin

# サンプルデータをロード
docker compose exec superset superset load-examples
```

### データベース接続

```bash
# PostgreSQL に接続
docker compose exec superset_postgres psql -U superset -d superset
```

## Superset 設定

`config/superset_config.py` で詳細設定が可能:

```python
# カスタム設定例
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
}

# キャッシュ設定
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_URL': 'redis://superset_redis:6379/0',
}

# アラート/レポート設定
ALERT_REPORTS_NOTIFICATION_DRY_RUN = True
```

## データソースの追加

1. Superset UI で「Settings」→「Database Connections」
2. 「+ DATABASE」をクリック
3. データベースタイプを選択し接続情報を入力

### 接続文字列の例

```
# PostgreSQL
postgresql://user:password@host:5432/database

# MySQL
mysql://user:password@host:3306/database

# ClickHouse
clickhouse+native://user:password@host:9000/database
```

## バックアップ

### データベースバックアップ

```bash
docker compose exec superset_postgres pg_dump -U superset superset > backup_$(date +%Y%m%d).sql
```

### データベースリストア

```bash
cat backup_20240101.sql | docker compose exec -T superset_postgres psql -U superset -d superset
```

## トラブルシューティング

### Superset が起動しない

1. PostgreSQL と Redis のヘルスチェック確認:
   ```bash
   docker compose ps
   ```

2. ログ確認:
   ```bash
   docker compose logs superset
   ```

3. データベースマイグレーションを実行:
   ```bash
   docker compose exec superset superset db upgrade
   ```

### ログインできない

1. Adminユーザーが作成されているか確認:
   ```bash
   docker compose exec superset superset fab list-users
   ```

2. パスワードリセット:
   ```bash
   docker compose exec superset superset fab reset-password --username admin --password new_password
   ```

### Celery Worker が動作しない

1. Redis接続を確認:
   ```bash
   docker compose exec superset_redis redis-cli ping
   ```

2. Workerログを確認:
   ```bash
   docker compose logs superset_worker
   ```

## 参考リンク

- [Apache Superset Documentation](https://superset.apache.org/docs/intro)
- [Apache Superset Docker Hub](https://hub.docker.com/r/apache/superset)
- [Apache Superset GitHub](https://github.com/apache/superset)
- [Superset Configuration](https://superset.apache.org/docs/installation/configuring-superset)
