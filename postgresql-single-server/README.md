# PostgreSQL

## 導入手順

1. .envを作成してください

```shell
# 雛形をコピーして作成
cp .env.example .env

# コピーしたら.envファイルを開き、シークレット情報を更新する(パスワードは複雑なものに更新すること!)
vi .env
```

2. 立ち上げる

limaを使っていて、dockerが動いていない場合は↓のコマンドを実行する

```shell
limactl start docker
```

PostgreSQLコンテナを立ち上げる

```shell
docker-compose up -d
```

## Postgresql 作業

dockerの中に入る

```shell
# docker-compose exec <service name> bash      
docker-compose exec local_postgres bash      
```

(dockerに入った上で)データベースに接続する

```shell
psql -U postgres -d app_dev
```

データベースから出る

```postgresql
\q
```

データベース一覧

```postgresql
psql -l
```

データベース切り替え

```postgresql
\c <db name>
```

テーブル一覧

```postgresql
\t
```

テーブルのスキーマ詳細

```postgresql
\d <table name>
```

VIEWの一覧

```postgresql
\dv
```

VIEWの定義詳細

```postgresql
select definition from pg_views where viewname = '<VIEW_NAME>';
```

テーブル名変更

```postgresql
alter table <CURRENT_DB_NAME> rename to <NEW_DB_NAME>;
```

テーブル削除

```postgresql
# (当然ですが)データも消えます
drop table <TABLE_NAME>;
```

スキーマ作成

```postgresql
create schema <schema name>;
```

スキーマ一覧

```postgresql
\dn
```

スキーマ確認

```postgresql
select current_schema;
```

スキーマ変更

```postgresql
set search_path to <schema name>;
```

現在のユーザ

```postgresql
select current_user;
```

ロールの一覧

```postgresql
\du
```

ユーザのロール一覧

```postgresql
select * from pg_user;
```

権限付与

```postgresql
grant select, insert, update, delete on <table name> to <user name>;
```

権限削除

```postgresql
revoke select, insert, update, delete on <table name> from <user name>;
```

ユーザをスーパーユーザに変更

```postgresql
alter role <user name> with creatural superuser;

# スーパーユーザを剥奪
alter role <user name> with creatural nosuperuser;
```

バックアップする

```postgresql
# portとuserは適宜変更する
pg_dumpall -h localhost -p 5432 -U postgres --exclude-database postgres | sed -E 's/^(CREATE|ALTER) ROLE/-- &/' > psql-dump-$(date "+%Y%m%dt%H%M%S").sql
```

## References
- https://mebee.info/2020/12/04/post-24686/
- https://zenn.dev/sarisia/articles/0c1db052d09921
