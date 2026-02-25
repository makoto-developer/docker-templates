# 環境変数管理ルール

> .env と .env.example の作成ガイドライン

## 基本原則

### 1. 機密情報は .env に隔離

- パスワード、APIキー、トークン等は `.env` ファイルで管理
- `.env` は `.gitignore` に必ず追加
- `.env.example` にはサンプル値のみ記載

### 2. すべての設定を環境変数化

ポート番号、ユーザー名、ディレクトリパス等、環境に依存する値はすべて環境変数化。

## 命名規則

### 大文字 + アンダースコア区切り

```bash
# ✅ 推奨
SERVER_NAME=postgres_single
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_here
TZ=Asia/Tokyo

# ❌ 避ける
serverName=postgres_single        # キャメルケース
postgres-port=5432                # ハイフン区切り
postgres.user=postgres            # ドット区切り
```

### プレフィックスの使用

サービス名をプレフィックスとして使用：

```bash
# PostgreSQL関連
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB_NAME=app_dev

# MySQL関連
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=password
MYSQL_DATABASE=app_dev
MYSQL_USER=app_user
MYSQL_PASSWORD=password
```

## 必須項目

すべての `.env.example` に以下の項目を含める：

```bash
# サービス名（コンテナ名に使用）
SERVER_NAME=service_name

# ポート番号
SERVICE_PORT=5432

# 認証情報
ADMIN_USER=admin
ADMIN_PASSWORD=change_me_to_secure_password

# タイムゾーン
TZ=Asia/Tokyo
```

## .env.example の作成ルール

### 1. サンプル値を記載

実際の値ではなく、わかりやすいサンプル値を記載：

```bash
# ✅ 推奨: .env.example
SERVER_NAME=postgres_single
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change_me_to_secure_password
POSTGRES_DB_NAME=app_dev
TZ=Asia/Tokyo

# ❌ 避ける: 実際のパスワードを記載
POSTGRES_PASSWORD=MySecretP@ssw0rd123
```

### 2. コメントで説明を追加

各変数の用途や制約をコメントで説明：

```bash
# コンテナ名（英数字とアンダースコアのみ）
SERVER_NAME=postgres_single

# PostgreSQL接続ポート（1024-65535）
POSTGRES_PORT=5432

# PostgreSQLスーパーユーザー名
POSTGRES_USER=postgres

# PostgreSQLパスワード（8文字以上推奨）
POSTGRES_PASSWORD=change_me_to_secure_password

# データベース名（英数字とアンダースコアのみ）
POSTGRES_DB_NAME=app_dev

# タイムゾーン（例: Asia/Tokyo, UTC）
TZ=Asia/Tokyo
```

### 3. セクション分けで整理

関連する変数をセクションごとにグループ化：

```bash
# ======================
# Server Configuration
# ======================
SERVER_NAME=postgres_single
TZ=Asia/Tokyo

# ======================
# Database Configuration
# ======================
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change_me_to_secure_password
POSTGRES_DB_NAME=app_dev

# ======================
# Advanced Settings
# ======================
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=256MB
```

## パスワードの扱い

### .env.example のパスワード

明確に変更が必要だとわかるプレースホルダーを使用：

```bash
# ✅ 推奨
POSTGRES_PASSWORD=change_me_to_secure_password
MYSQL_ROOT_PASSWORD=CHANGE_THIS_PASSWORD
API_KEY=your_api_key_here
SECRET_KEY=generate_secure_random_string

# ❌ 避ける: 簡単すぎるパスワード
POSTGRES_PASSWORD=password
POSTGRES_PASSWORD=123456

# ❌ 避ける: 実際のパスワード
POSTGRES_PASSWORD=MyActualSecretPassword123
```

### パスワード生成方法を記載

README.md にパスワード生成方法を記載：

```bash
# ランダムパスワード生成（macOS/Linux）
openssl rand -base64 32

# または
LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32
```

## ポート番号の割り当て

### 標準ポートを避ける

本番環境との競合を避けるため、開発環境では非標準ポートを使用：

```bash
# ✅ 推奨: 非標準ポート
POSTGRES_PORT=15432     # 標準: 5432
MYSQL_PORT=13306        # 標準: 3306
REDIS_PORT=16379        # 標準: 6379

# ❌ 避ける: 標準ポート（競合の可能性）
POSTGRES_PORT=5432
MYSQL_PORT=3306
REDIS_PORT=6379
```

### ポート範囲の目安

```bash
# データベース: 10000-19999
POSTGRES_PORT=15432
MYSQL_PORT=13306

# Webアプリ: 20000-29999
SUPERSET_PORT=22410
JIRA_PORT=28080

# メッセージキュー: 30000-39999
RABBITMQ_PORT=35672

# その他: 40000-49999
ELASTICSEARCH_PORT=49200
```

## 複数環境の管理

### 環境別の .env ファイル

開発、ステージング、本番で異なる設定が必要な場合：

```bash
.env.development
.env.staging
.env.production
```

使用時は以下のようにシンボリックリンクまたはコピー：

```bash
# 開発環境
cp .env.development .env

# または
ln -sf .env.development .env
```

## .gitignore の設定

`.env` ファイルは必ず `.gitignore` に追加：

```gitignore
# Environment variables
.env
.env.local
.env.*.local

# Exclude but keep examples
!.env.example
!.env.*.example
```

## 検証チェックリスト

環境変数ファイル作成後、以下を確認：

- [ ] `.env.example` にすべての必要な変数が含まれている
- [ ] 各変数にコメントで説明が記載されている
- [ ] パスワードはプレースホルダー（実際の値ではない）
- [ ] ポート番号は非標準ポートを使用
- [ ] 命名規則（大文字+アンダースコア）に従っている
- [ ] `.env` が `.gitignore` に追加されている
- [ ] セクション分けで整理されている（10個以上の変数がある場合）
- [ ] README.md に環境変数の設定方法を記載

## docker-compose.yml での参照方法

環境変数は `${VARIABLE_NAME}` 形式で参照：

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB_NAME}
  TZ: ${TZ}

ports:
  - "${POSTGRES_PORT}:5432"

container_name: ${SERVER_NAME}
```

デフォルト値を設定する場合：

```yaml
environment:
  # デフォルト値: postgres
  POSTGRES_USER: ${POSTGRES_USER:-postgres}

  # デフォルト値: Asia/Tokyo
  TZ: ${TZ:-Asia/Tokyo}
```
