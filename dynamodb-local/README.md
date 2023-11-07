# DynamoDB Local

ローカルでDynamoDBの環境を作り出す

## Starting

create `.env` file. And edit setting if you need to change default settins.

```shell
cp .env.example .env
```

start docker compose server


```shell
docker compose up
```

## Access DynamoDB Local

command line(change port if edit .env and change dynamodb port.

```shell
aws dynamodb list-tables --endpoint-url http://localhost:47000
```

programming languages

```text
refer to aws sdk package by your language.
```


## Reference
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html


