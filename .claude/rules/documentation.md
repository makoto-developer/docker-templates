# ドキュメント作成ルール

> README.md 作成時のガイドライン

## README.md の必須セクション

各サービスの README.md には以下のセクションを含める：

```markdown
# サービス名

## 概要（該当する場合）
- サービスの説明
- 新機能の紹介（データベースの場合）

## 導入手順
- 環境変数ファイルの作成
- 設定方法
- 起動方法

## 起動・停止
- 基本的なコマンド

## コンテナ操作
- コンテナへのアクセス方法
- サービス固有のコマンド

## サービス固有コマンド集
- よく使うコマンド

## 管理者作業（該当する場合）
- ユーザー管理
- バックアップ・リストア

## トラブルシューティング
- よくある問題と解決方法

## 参考リンク
- 公式ドキュメント等
```

## セクション別ガイドライン

### 1. タイトル

```markdown
# PostgreSQL

# MySQL

# Elasticsearch + Kibana
```

サービス名を簡潔に記載。バージョン番号は不要（docker-compose.yml で管理）。

### 2. 概要・新機能紹介

データベースの場合、新バージョンの主要機能を紹介：

```markdown
## PostgreSQL 18新機能
- 非同期I/Oの導入
  - I/O処理を依頼すると処理が終了して結果が返ってくるまで同一プロセスorスレッドの処理が一時停止していたが、今回は非同期で読み込みすることで速度が3倍速くなった
  - 非同期I/O処理をシーケンシャルスキャン、ビットマップヒープスキャン、バキューム処理で非同期処理に変更
- UUID v7
  - uidv7()関数を新たに追加
  - 重複のない一意な128ビット長のID
  - IDにミリ秒単位のタイムスタンプが格納され、時系列でソート可能になった
```

### 3. 導入手順

環境変数ファイルの作成から起動までを記載：

```markdown
## 導入手順

`.env`を作成

\`\`\`shell
cp .env.example .env
\`\`\`

ポート番号やサービスの情報を編集

\`\`\`shell
vi .env
\`\`\`

コンテナを立ち上げる

\`\`\`shell
docker compose up -d
\`\`\`
```

### 4. 起動・停止

基本的なDocker Composeコマンドを記載：

```markdown
## 起動、停止

起動

\`\`\`shell
docker compose start
\`\`\`

停止

\`\`\`shell
docker compose stop
\`\`\`

Composeを削除

\`\`\`shell
docker compose down
\`\`\`

ボリュームも削除

\`\`\`shell
docker compose down -v
\`\`\`
```

### 5. コンテナ操作

コンテナへのアクセス方法とサービス接続方法を記載：

```markdown
## コンテナにアクセス

dockerの中に入る

\`\`\`shell
docker compose exec <service name> bash
\`\`\`

(dockerに入った上で)データベースに接続する

\`\`\`shell
psql -U postgres -d app_dev
\`\`\`
```

### 6. サービス固有コマンド集

そのサービスでよく使うコマンドを分類して記載：

```markdown
## PostgreSQLコマンド集

### スキーマ

\`\`\`sql
-- スキーマ一覧
\\dn

-- スキーマ作成
CREATE SCHEMA schema_name;

-- 現在いるスキーマを確認
SELECT current_schema();
\`\`\`

### データベース操作

\`\`\`sql
-- データベース一覧
\\l

-- データベースを作成する
CREATE DATABASE database_name;

-- 現在のデータベース
SELECT current_database();
\`\`\`
```

### 7. 管理者作業

ユーザー管理、バックアップ等を記載：

```markdown
## 管理者作業

### ユーザー管理

\`\`\`sql
-- 現在のユーザ
SELECT current_user;

-- ロールの一覧
\\du

-- 権限付与
GRANT SELECT, INSERT, UPDATE, DELETE ON table_name TO user_name;
\`\`\`

### バックアップ

\`\`\`bash
# バックアップする
pg_dumpall -h localhost -p 5432 -U postgres > backup_$(date "+%Y%m%dt%H%M%S").sql
\`\`\`
```

### 8. トラブルシューティング

よくある問題と解決方法を記載：

```markdown
## トラブルシューティング

### コンテナが起動しない

1. ポートが既に使用されていないか確認：
   \`\`\`bash
   lsof -i :5432
   \`\`\`

2. ログを確認：
   \`\`\`bash
   docker compose logs
   \`\`\`

3. ボリュームを削除して再起動：
   \`\`\`bash
   docker compose down -v
   docker compose up -d
   \`\`\`

### データベースに接続できない

1. ヘルスチェックの状態を確認：
   \`\`\`bash
   docker compose ps
   \`\`\`

2. パスワードが正しいか確認：
   \`\`\`bash
   cat .env | grep PASSWORD
   \`\`\`
```

### 9. 参考リンク

公式ドキュメント等のリンクを記載：

```markdown
## References
- https://www.postgresql.org/docs/
- https://mebee.info/2020/12/04/post-24686/
- https://zenn.dev/sarisia/articles/0c1db052d09921
```

## マークダウン記法のルール

### コードブロックの言語指定

```markdown
# ✅ 推奨: 言語を明示
\`\`\`bash
docker compose up -d
\`\`\`

\`\`\`sql
SELECT * FROM users;
\`\`\`

\`\`\`yaml
services:
  db:
    image: postgres:18-alpine
\`\`\`

# ❌ 避ける: 言語指定なし
\`\`\`
docker compose up -d
\`\`\`
```

### コマンドの前に説明を追加

```markdown
# ✅ 推奨: コマンドの前に説明
環境変数ファイルを作成

\`\`\`bash
cp .env.example .env
\`\`\`

# ❌ 避ける: 説明なし
\`\`\`bash
cp .env.example .env
\`\`\`
```

### テーブルの活用

環境変数一覧、サービス一覧等はテーブルで記載：

```markdown
## 環境変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| SERVER_NAME | postgres_single | コンテナ名 |
| POSTGRES_PORT | 5432 | 接続ポート |
| POSTGRES_USER | postgres | ユーザー名 |
| POSTGRES_PASSWORD | - | パスワード |
```

### 図表の活用

構成図やネットワーク図を追加（該当する場合）：

```markdown
## 構成

\`\`\`
┌─────────────────────────────────────────────────┐
│                    Kibana                       │
│                  localhost:5601                 │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│               Elasticsearch                      │
│                localhost:9200                    │
└─────────────────────────────────────────────────┘
\`\`\`
```

## コメントの書き方

### SQLコマンドにコメント

```sql
-- データベース一覧
\l

-- データベースを作成する
CREATE DATABASE database_name;
```

### Bashコマンドにコメント

```bash
# portとuserは適宜変更する
pg_dumpall -h localhost -p 5432 -U postgres > backup.sql
```

## ファイル構成図

複雑なディレクトリ構造の場合、ファイル構成図を記載：

```markdown
## ディレクトリ構造

\`\`\`
apache_superset/
├── docker-compose.yml    # Docker Compose 設定
├── .env.example          # 環境変数テンプレート
├── .gitignore            # Git 無視ファイル設定
├── config/               # Superset 設定ファイル
│   └── superset_config.py
├── init/                 # PostgreSQL 初期化スクリプト
├── logs/                 # ログファイル
│   ├── superset/
│   └── postgres/
└── README.md             # このファイル
\`\`\`
```

## 検証チェックリスト

README.md 作成後、以下を確認：

- [ ] すべての必須セクションが含まれている
- [ ] コマンドは実際に動作する
- [ ] コードブロックに言語指定がある
- [ ] コマンドの前に簡潔な説明がある
- [ ] テーブルで整理されている（該当する場合）
- [ ] トラブルシューティングセクションがある
- [ ] 参考リンクが記載されている
- [ ] マークダウンの文法エラーがない
- [ ] 日本語で記載されている

## 言語

- **日本語**: README、コメントは日本語で記載
- **英語**: コマンド、変数名、関数名等の技術用語はそのまま
