# Keycloak テンプレート

Keycloak（認証・認可サーバー）のローカル開発環境テンプレートです。

## 構成

```
┌─────────────────────────────────────────────────┐
│                   Keycloak                       │
│                localhost:11000                   │
│            (認証・認可サーバー)                   │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                  PostgreSQL                      │
│                (内部ネットワーク)                 │
└─────────────────────────────────────────────────┘
```

## サービス

| サービス | ポート | 説明 |
|---------|-------|------|
| Keycloak | 11000 | 認証・認可サーバー |
| PostgreSQL | - | データベース（内部のみ） |

## 使い方

### 1. 環境設定

```bash
cp .env.example .env
# .env を編集してパスワードを設定
```

### 2. 起動

```bash
docker compose up -d
```

### 3. 管理コンソールアクセス

ブラウザで http://localhost:11000 にアクセス

**デフォルト管理者アカウント:**
- ユーザー名: `admin`
- パスワード: `.env` の `KEYCLOAK_ADMIN_PASSWORD`

## 環境変数

| 変数名 | 説明 |
|--------|------|
| POSTGRES_PASSWORD | PostgreSQLパスワード（必須） |
| KEYCLOAK_DB_PASSWORD | KeycloakのDB接続パスワード（必須） |
| KEYCLOAK_ADMIN_PASSWORD | 管理者パスワード（必須） |

## 基本的な設定手順

### 1. Realm作成

1. 管理コンソールにログイン
2. 左上のドロップダウン → "Create Realm"
3. Realm名を入力して作成

### 2. クライアント作成

1. Clients → Create client
2. Client ID を入力
3. Client authentication を有効化（機密クライアントの場合）
4. Valid redirect URIs を設定

### 3. ユーザー作成

1. Users → Add user
2. ユーザー情報を入力
3. Credentials タブでパスワード設定

## OpenID Connect エンドポイント

```
# Well-known設定
http://localhost:11000/realms/{realm}/.well-known/openid-configuration

# 認可エンドポイント
http://localhost:11000/realms/{realm}/protocol/openid-connect/auth

# トークンエンドポイント
http://localhost:11000/realms/{realm}/protocol/openid-connect/token

# ユーザー情報エンドポイント
http://localhost:11000/realms/{realm}/protocol/openid-connect/userinfo
```

## 開発モードについて

このテンプレートは `start-dev` モードで起動します：
- HTTPで動作（本番ではHTTPS必須）
- 開発用の設定が有効

**本番環境では使用しないでください。**

## 停止・削除

```bash
# 停止
docker compose down

# データも含めて削除
docker compose down -v
```

## 参考

- [Keycloak ドキュメント](https://www.keycloak.org/documentation)
- [Keycloak Admin REST API](https://www.keycloak.org/docs-api/latest/rest-api/index.html)
