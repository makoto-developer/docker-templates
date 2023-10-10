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

command line

```shell
aws dynamodb list-tables --endpoint-url http://localhost:8000
```

programming languages

refer to aws sdk package by your language.


## Reference
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html


