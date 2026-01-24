# MySQL Cluster テンプレート

MySQL レプリケーション構成（1 Primary + 2 Replica）のローカル開発環境テンプレートです。

## 構成

```
                    ┌─────────────────┐
                    │    ProxySQL     │
                    │  :6033 (MySQL)  │
                    │  :6032 (Admin)  │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ▼                 ▼                 ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  mysql-primary  │ │ mysql-replica1  │ │ mysql-replica2  │
│     :3306       │ │     :3307       │ │     :3308       │
│   (読み書き)    │ │   (読み取り)    │ │   (読み取り)    │
└─────────────────┘ └─────────────────┘ └─────────────────┘
        │                   ▲                   ▲
        │                   │                   │
        └───────────────────┴───────────────────┘
                    レプリケーション
```

## サービス

| サービス | ポート | 説明 |
|---------|-------|------|
| mysql-primary | 3306 | プライマリ（読み書き） |
| mysql-replica1 | 3307 | レプリカ1（読み取り専用） |
| mysql-replica2 | 3308 | レプリカ2（読み取り専用） |
| proxysql | 6033 | 負荷分散・接続プール |
| proxysql (admin) | 6032 | ProxySQL管理 |

## 使い方

### 1. 環境設定

```bash
cp .env.example .env
# .env を編集してパスワードを設定
```

### 2. 起動

```bash
docker compose up -d
```

### 3. レプリケーション確認

```bash
# プライマリでレプリケーション状態確認
docker exec mysql-primary mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW MASTER STATUS\G"

# レプリカでレプリケーション状態確認
docker exec mysql-replica1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW REPLICA STATUS\G"
```

## 環境変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| MYSQL_ROOT_PASSWORD | ChangeThisRootPassword123! | rootパスワード |
| MYSQL_APP_PASSWORD | ChangeThisAppPassword123! | アプリ用パスワード |
| MYSQL_REPL_PASSWORD | ChangeThisReplPassword123! | レプリケーション用パスワード |

## 接続方法

### 直接接続

```bash
# プライマリ（書き込み可）
mysql -h 127.0.0.1 -P 3306 -uroot -p

# レプリカ1（読み取り専用）
mysql -h 127.0.0.1 -P 3307 -uroot -p

# レプリカ2（読み取り専用）
mysql -h 127.0.0.1 -P 3308 -uroot -p
```

### ProxySQL経由

```bash
# 自動的に読み書き分離
mysql -h 127.0.0.1 -P 6033 -uroot -p
```

## レプリケーションの仕組み

### GTID (Global Transaction Identifier)

このテンプレートはGTIDベースのレプリケーションを使用：

```sql
-- プライマリで有効
gtid-mode=ON
enforce-gtid-consistency=ON

-- レプリカで有効
read-only=1
```

### 書き込みテスト

```bash
# プライマリに書き込み
docker exec mysql-primary mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "CREATE DATABASE testdb; USE testdb; CREATE TABLE t1 (id INT PRIMARY KEY);"

# レプリカで確認（数秒後に反映）
docker exec mysql-replica1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW DATABASES;"
```

## ファイル構成

```
mysql-cluster-server/
├── docker-compose.yml      # サービス定義
├── .env.example            # 環境変数テンプレート
├── .gitignore              # Git除外設定
├── config/
│   └── primary.cnf         # プライマリ設定
├── init-primary.sql        # プライマリ初期化SQL
├── init-replica.sh         # レプリカ初期化スクリプト
├── proxysql.cnf            # ProxySQL設定
└── logs/                   # ログディレクトリ
    └── primary/
```

## トラブルシューティング

### レプリケーションが停止した場合

```bash
# レプリカでエラー確認
docker exec mysql-replica1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW REPLICA STATUS\G" | grep -E "(Last_Error|Seconds_Behind)"

# レプリケーション再開
docker exec mysql-replica1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
  -e "STOP REPLICA; START REPLICA;"
```

### データ不整合の場合

```bash
# レプリカを再構築
docker compose stop mysql-replica1
docker volume rm mysql-cluster-server_mysql-replica1-data
docker compose up -d mysql-replica1
```

## 停止・削除

```bash
# 停止
docker compose down

# データも含めて削除
docker compose down -v
```

## 参考

- [MySQL Replication](https://dev.mysql.com/doc/refman/8.0/en/replication.html)
- [GTID Replication](https://dev.mysql.com/doc/refman/8.0/en/replication-gtids.html)
- [ProxySQL Documentation](https://proxysql.com/documentation/)
