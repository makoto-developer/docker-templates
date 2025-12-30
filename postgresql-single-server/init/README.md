# 初期化スクリプトディレクトリ

このディレクトリ内のスクリプトは、PostgreSQLコンテナの初回起動時に自動実行されます。

## 実行順序

ファイル名のアルファベット順に実行されます:
- `01-init.sql`
- `02-users.sql`
- `03-schema.sql`

## 使い方

### SQLスクリプトの追加

初期データベーススキーマやユーザーを作成する場合:

```sql
-- 01-init.sql
CREATE SCHEMA IF NOT EXISTS app_schema;

CREATE TABLE IF NOT EXISTS app_schema.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### シェルスクリプトの使用

より複雑な初期化が必要な場合は `.sh` スクリプトも使用可能:

```bash
#!/bin/bash
# 02-custom-setup.sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER app_user WITH PASSWORD 'secure_password';
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO app_user;
EOSQL
```

## 注意事項

- スクリプトは**初回起動時のみ**実行されます
- データボリュームが既に存在する場合は実行されません
- 再実行するには `data/pgdata` を削除してコンテナを再作成する必要があります
- スクリプトはコンテナ内の `postgres` ユーザー権限で実行されます

## 環境変数

スクリプト内で使用可能な環境変数:
- `$POSTGRES_USER` - PostgreSQLのスーパーユーザー名
- `$POSTGRES_PASSWORD` - スーパーユーザーのパスワード
- `$POSTGRES_DB` - デフォルトデータベース名

## サンプルスクリプト

プロジェクトのルートディレクトリにある `sample.sql` を参考にしてください。
