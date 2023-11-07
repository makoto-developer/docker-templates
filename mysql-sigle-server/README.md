# MySQL

## Feature

|key|value|
|:---:|:---|
|_|MySQL Adminのserviceを追加|
|_|mysqlコンテナに入ってselectするまでの手順を追加|
|_||
|_||
|_||

## 導入手順

`.env`を作成

```shell
cp .env.example .env
```

`.env`ファイルを開き、シークレット情報を更新する(パスワードは複雑なものに更新すること!)

```shell
vi .env
```

MySQLコンテナを立ち上げる

```shell
docker compose up -d
```

