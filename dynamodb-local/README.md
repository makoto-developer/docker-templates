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

## 

```shell
mkdir  ~/.aws
vi  ~/.aws/credentials
-----
[default]
aws_access_key_id = DUMMYIDEXAMPLE # ここの値はAWS_ACCESS_KEY_IDを参照
aws_secret_access_key = DUMMYEXAMPLEKE # AWS_SECRET_ACCESS_KEYを参照
-----
vi ~/.aws/config
-----
[default]
region = us-west-2
endpoint_url = http://localhost:8000
-----
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

## NoSQL Workbench(GUI)

https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/workbench.settingup.html


## Reference
- https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html


