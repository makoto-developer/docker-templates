# Docker Templates プロジェクト

> 各種データベースとツールのDocker環境構築テンプレート集

## プロジェクト概要

このリポジトリは、開発環境でよく使うミドルウェアをすぐに立ち上げられるように、Docker Compose設定とドキュメントを整備したテンプレート集です。

**含まれるサービス:**
- データベース: PostgreSQL 18, MySQL 9, Elasticsearch, DynamoDB Local, SurrealDB, Dgraph, FoundationDB
- メッセージキュー: RabbitMQ
- データ分析: Apache Superset, Jupyter Lab
- プロジェクト管理: Jira
- 認証: Keycloak
- その他: Docker Network設定サンプル

## 重要な原則

### 1. 各サービスは独立したディレクトリ

新しいサービスを追加する際は、以下の構造を維持：

```
service-name/
├── docker-compose.yml
├── .env.example
├── README.md
├── .gitignore
├── config/          # 設定ファイル（該当する場合）
└── init/            # 初期化スクリプト（該当する場合）
```

### 2. 環境変数による設定管理

- すべての機密情報（パスワード等）は環境変数で管理
- `.env.example` にサンプル値を記載
- 実際の `.env` ファイルは `.gitignore` に追加

### 3. 詳細なドキュメント

各サービスの `README.md` には以下を必ず含める：
- 概要・新機能紹介
- 導入手順
- 起動・停止方法
- よく使うコマンド
- トラブルシューティング

## よく使うコマンド

### 新しいサービス追加時

```bash
# ディレクトリ作成
mkdir service-name && cd service-name

# 必須ファイル作成
touch docker-compose.yml .env.example README.md .gitignore

# .gitignore に .env を追加
echo ".env" >> .gitignore
```

### 動作確認

```bash
# 環境変数ファイル作成
cp .env.example .env

# コンテナ起動
docker compose up -d

# ログ確認
docker compose logs -f

# 停止・削除
docker compose down -v
```

## 検証方法

新しいテンプレート追加・既存テンプレート修正時：

1. **起動確認**: `docker compose up -d`
2. **ヘルスチェック**: `docker compose ps`
3. **ログ確認**: `docker compose logs`
4. **ドキュメント更新**: README.md, .env.example
5. **停止・削除**: `docker compose down -v`

## 追加ルール

詳細なルールは `.claude/rules/` を参照：
- @.claude/rules/docker-compose.md - Docker Compose設定ルール
- @.claude/rules/documentation.md - ドキュメント作成ルール
- @.claude/rules/security.md - セキュリティベストプラクティス
- @.claude/rules/env-variables.md - 環境変数管理ルール

## 禁止事項

- ❌ `.env` ファイルをコミットしない
- ❌ 実際のパスワードを `.env.example` に記載しない
- ❌ データディレクトリ（volumes）をコミットしない
- ❌ コード品質チェック（lint, format, test）は不要（設定ファイル集のため）
