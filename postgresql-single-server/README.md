# PostgreSQL

## PostgreSQL 18新機能
- 非同期I/Oの導入
  - I/O処理を依頼すると処理が終了して結果が返ってくるまで同一プロセスorスレッドの処理が一時停止していたが、今回は非同期で読み込みすることで速度が3倍速くなった
  - 非同期I/O処理をシーケンシャルスキャン、ビットマップヒープスキャン、バキューム処理で非同期処理に変更
- UUID v7
  - uidv7()関数を新たに追加
  - 重複のない一意な128ビット長のID
  - IDにミリ秒単位のタイムスタンプが格納され、時系列でソート可能になった
  - 生成順にIDが隣接するためにインデクス生成で近接された領域に格納されるのでI/O処理の面で有利となる
- oauth認証機能
  - md5パスワード認証が非推奨
  - パスワードベースの認証が必要な場合にSCRAM認証を使用すること
- 全てのリリース機能の説明
  - https://www.postgresql.org/docs/18/release-18.html
  
## PostgreSQL 17新機能
- インクリメンタルバックアップ
- パーティションテーブルでIDENTITY列をサポート
- パーティションテーブルで排他制約を使用可能に
- MERGEコマンド機能 
  - 単一のステートメントで条件付きの更新、挿入、削除が可能
  - https://www.postgresql.jp/docs/17/sql-merge.html
- JSONデータをテーブル形式に変換するための関数JSON_TABLE()を導入
- 全てのリリース機能の説明
  - https://www.postgresql.org/docs/17/release-17.html

## 導入手順

`.env`を作成

```shell
cp .env.example .env
```

ポート番号やPSQLの情報を編集

```shell
vi .env
```

PostgreSQLコンテナを立ち上げる

```shell
docker compose up -d
```

## 起動、停止

起動

```shell
docker compose start
```

停止

```shell
docker compose stop
```

Composeを削除

```shell
docker compose down
```

## コンテナにアクセス

dockerの中に入る

```shell
docker compose exec <service name> bash      
```

(dockerに入った上で)データベースに接続する

```shell
psql -U postgres -d app_dev
sudo -u postgres psql
```

## PostgreSQLコマンド集

スキーマ

```sql
-- スキーマ一覧
\dn

-- スキーマ作成
create schema <<schema_name>>;

-- 現在いるスキーマを確認
select current_schema();

-- スキーマを切り替える
SET search_path = <<schema_name>>;

-- スキーマ名を変更
ALTER SCHEMA <<before_scheama_name>> RENAME TO <<new_schema_name>>;

-- 削除
DROP SCHEMA schema_name
```

データベース操作

```sql
-- データベース一覧
\l

-- データベースを作成する
create database <<database_name>>;


-- 現在のデータベース
select current_database();

-- データベース切り替え
\c <db name>

-- データベースから出る
\q

-- データベース名を変更
ALTER DATABASE <<before_name>> RENAME TO <<after_name>>
```

テーブル操作

```sql
-- テーブル一覧
\dt

-- DDLを表示
\d table_name

-- テーブル名変更
alter table <CURRENT_DB_NAME> rename to <NEW_DB_NAME>;

-- テーブル削除
drop table <TABLE_NAME>;

-- VIEWの一覧
\dv

-- VIEWの定義詳細
select definition from pg_views where viewname = '<VIEW_NAME>';
```

## 管理者作業

```sql
-- 現在のユーザ
select current_user;

-- ロールの一覧
\du

-- ユーザのロール一覧
select * from pg_user;

-- 権限付与
grant select, insert, update, delete on <table name> to <user name>;

-- 権限削除
revoke select, insert, update, delete on <table name> from <user name>;

-- ユーザをスーパーユーザに変更
alter role <user name> with creatural superuser;

-- スーパーユーザを剥奪
alter role <user name> with creatural nosuperuser;

-- バックアップする
-- # portとuserは適宜変更する
pg_dumpall -h localhost -p 5432 -U postgres --exclude-database postgres | sed -E 's/^(CREATE|ALTER) ROLE/-- &/' > psql-dump-$(date "+%Y%m%dt%H%M%S").sql
```

## References
- https://mebee.info/2020/12/04/post-24686/
- https://zenn.dev/sarisia/articles/0c1db052d09921

