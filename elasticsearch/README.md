# Elasticsearch + Kibana テンプレート

Elasticsearch と Kibana のローカル開発環境テンプレートです。

## 構成

```
┌─────────────────────────────────────────────────┐
│                    Kibana                       │
│                  localhost:5601                 │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│               Elasticsearch                      │
│                localhost:9200                    │
│            (シングルノード構成)                   │
└─────────────────────────────────────────────────┘
```

## サービス

| サービス | ポート | 説明 |
|---------|-------|------|
| Elasticsearch | 9200 | 検索・分析エンジン |
| Kibana | 5601 | 可視化ダッシュボード |

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

### 3. 動作確認

```bash
# Elasticsearch ヘルスチェック
curl -X GET "localhost:9200/_cluster/health?pretty"

# インデックス一覧
curl -X GET "localhost:9200/_cat/indices?v"
```

### 4. Kibana アクセス

ブラウザで http://localhost:5601 にアクセス

## 環境変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| STACK_VERSION | 8.11.0 | Elastic Stackバージョン |
| ES_PORT | 9200 | Elasticsearchポート |
| ELASTIC_PASSWORD | - | Elasticsearchパスワード |
| KIBANA_PORT | 5601 | Kibanaポート |
| KIBANA_PASSWORD | - | Kibanaパスワード |
| I18N_LOCALE | ja-JP | Kibana言語設定 |
| MEM_LIMIT | 1073741824 | メモリ制限（1GB） |

## サンプルデータ投入

```bash
# ドキュメント作成
curl -X POST "localhost:9200/my-index/_doc/1?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"title": "テスト", "content": "Elasticsearchのテストです"}'

# 検索
curl -X GET "localhost:9200/my-index/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"query": {"match": {"content": "テスト"}}}'
```

## トラブルシューティング

### vm.max_map_count エラー

Elasticsearchが起動しない場合、以下を実行：

```bash
# Linux
sudo sysctl -w vm.max_map_count=262144

# macOS (Docker Desktop)
# Docker Desktop の設定で Resources > Advanced からメモリを増やす
```

### メモリ不足

`.env` の `MEM_LIMIT` を調整（最低512MB推奨）

## 停止・削除

```bash
# 停止
docker compose down

# データも含めて削除
docker compose down -v
```

## 参考

- [Elasticsearch ドキュメント](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana ドキュメント](https://www.elastic.co/guide/en/kibana/current/index.html)
