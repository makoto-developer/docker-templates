# MySQL

## 導入手順

1. .envを作成

```shell
# 雛形をコピーして作成
cp .env.example .env

# .envファイルを開き、シークレット情報を更新する(パスワードは複雑なものに更新すること!)
vi .env
```

2. 立ち上げる

limaを使っていて、dockerが動いていない場合は↓のコマンドを実行する

```shell
limactl start docker
```

MySQLコンテナを立ち上げる

```shell
docker-compose up -d
```
