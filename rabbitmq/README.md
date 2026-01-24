# RabbitMQ テンプレート

RabbitMQ（メッセージブローカー）のローカル開発環境テンプレートです。

## 構成

```
┌─────────────────────────────────────────────────┐
│              RabbitMQ Management                 │
│                localhost:15672                   │
│              (管理UI・API)                       │
└─────────────────────────────────────────────────┘
                      │
┌─────────────────────────────────────────────────┐
│                  RabbitMQ                        │
│                localhost:5672                    │
│              (AMQP プロトコル)                   │
└─────────────────────────────────────────────────┘
```

## サービス

| サービス | ポート | 説明 |
|---------|-------|------|
| RabbitMQ | 5672 | AMQPプロトコル |
| Management UI | 15672 | 管理画面・REST API |

## 使い方

### 1. 環境設定

```bash
cp .env.example .env
# .env を編集してパスワード等を設定
```

### 2. 起動

```bash
docker compose up -d
```

### 3. 管理画面アクセス

ブラウザで http://localhost:15672 にアクセス

**デフォルトアカウント:**
- ユーザー名: `.env` の `RABBITMQ_USER_NAME`
- パスワード: `.env` の `RABBITMQ_USER_PASSWORD`

## 環境変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| SERVER_NAME | rabbitmq_docker | サーバー名 |
| RABBITMQ_PORT | 5672 | AMQPポート |
| RABBITMQ_UI_PORT | 15672 | 管理UIポート |
| RABBITMQ_USER_NAME | root | ユーザー名 |
| RABBITMQ_USER_PASSWORD | - | パスワード |
| TZ | Asia/Tokyo | タイムゾーン |

## 接続例

### Python (pika)

```python
import pika

connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host='localhost',
        port=5672,
        credentials=pika.PlainCredentials('root', 'your_password')
    )
)
channel = connection.channel()

# キュー作成
channel.queue_declare(queue='hello')

# メッセージ送信
channel.basic_publish(exchange='', routing_key='hello', body='Hello World!')
print(" [x] Sent 'Hello World!'")

connection.close()
```

### Node.js (amqplib)

```javascript
const amqp = require('amqplib');

async function main() {
  const connection = await amqp.connect('amqp://root:your_password@localhost:5672');
  const channel = await connection.createChannel();

  const queue = 'hello';
  await channel.assertQueue(queue);

  channel.sendToQueue(queue, Buffer.from('Hello World!'));
  console.log(" [x] Sent 'Hello World!'");

  await channel.close();
  await connection.close();
}

main();
```

## 管理API

```bash
# キュー一覧
curl -u root:your_password http://localhost:15672/api/queues

# 接続一覧
curl -u root:your_password http://localhost:15672/api/connections

# ノード情報
curl -u root:your_password http://localhost:15672/api/nodes
```

## 停止・削除

```bash
# 停止
docker compose down

# データも含めて削除
docker compose down -v
```

## 参考

- [RabbitMQ ドキュメント](https://www.rabbitmq.com/documentation.html)
- [Management Plugin](https://www.rabbitmq.com/management.html)
- [AMQP 0-9-1 Model](https://www.rabbitmq.com/tutorials/amqp-concepts.html)
