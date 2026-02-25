# セキュリティベストプラクティス

> Docker環境のセキュリティガイドライン

## 機密情報の管理

### 1. 環境変数の使用

機密情報は必ず環境変数で管理：

```yaml
# ✅ 推奨: 環境変数
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  API_KEY: ${API_KEY}
  SECRET_KEY: ${SECRET_KEY}

# ❌ 避ける: ハードコード
environment:
  POSTGRES_PASSWORD: "my_secret_password"
  API_KEY: "sk-1234567890abcdef"
```

### 2. .env ファイルの保護

```bash
# .gitignore に必ず追加
echo ".env" >> .gitignore

# ファイルパーミッションを制限（Linux/macOS）
chmod 600 .env
```

### 3. .env.example の安全性

実際のパスワードやキーを `.env.example` に記載しない：

```bash
# ✅ 推奨: .env.example
POSTGRES_PASSWORD=change_me_to_secure_password
API_KEY=your_api_key_here
SECRET_KEY=generate_secure_random_string

# ❌ 避ける: 実際の値
POSTGRES_PASSWORD=MySecretP@ssw0rd123
API_KEY=sk-1234567890abcdef
```

## パスワードの強度

### 推奨される強度

- **最低文字数**: 12文字以上
- **文字種**: 大文字、小文字、数字、記号を含む
- **辞書攻撃対策**: 辞書に載っている単語を避ける

### パスワード生成方法

```bash
# ランダムパスワード生成（macOS/Linux）
openssl rand -base64 32

# 英数字記号混在（32文字）
LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 32

# UUID形式
uuidgen
```

## ネットワークセキュリティ

### 1. 内部ネットワークの使用

外部アクセスが不要なサービスは `internal: true` を設定：

```yaml
networks:
  # データベース専用ネットワーク（外部からアクセス不可）
  db-net:
    driver: bridge
    internal: true  # 外部アクセス遮断
```

### 2. ポートの公開範囲を制限

必要最小限のポートのみ公開：

```yaml
# ✅ 推奨: ローカルホストのみにバインド
ports:
  - "127.0.0.1:5432:5432"

# ❌ 避ける: すべてのインターフェースに公開
ports:
  - "5432:5432"
```

### 3. 複数ネットワークの分離

フロントエンド、バックエンド、データベースを分離：

```yaml
services:
  frontend:
    networks:
      - frontend-net

  api:
    networks:
      - frontend-net  # フロントエンドと通信
      - backend-net   # バックエンドと通信

  db:
    networks:
      - backend-net   # APIのみアクセス可能

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
    internal: true  # 外部アクセス不可
```

## コンテナセキュリティ

### 1. 非rootユーザーでの実行

可能な限り非rootユーザーでコンテナを実行：

```yaml
services:
  api:
    user: "1000:1000"  # UID:GID
```

### 2. 読み取り専用のルートファイルシステム

データの書き込みが不要な場合は読み取り専用に：

```yaml
services:
  api:
    read_only: true
    tmpfs:
      - /tmp  # 一時ファイル用
```

### 3. ボリュームのマウント権限

設定ファイルは読み取り専用でマウント：

```yaml
volumes:
  # ✅ 推奨: 読み取り専用
  - ./config:/etc/config:ro

  # ❌ 避ける: 読み書き可能（不要な場合）
  - ./config:/etc/config
```

## イメージセキュリティ

### 1. 公式イメージの使用

信頼できる公式イメージを使用：

```yaml
# ✅ 推奨: 公式イメージ
image: postgres:18-alpine
image: redis:7-alpine
image: nginx:1.25-alpine

# ❌ 避ける: 非公式イメージ
image: randomuser/postgres:latest
```

### 2. タグの明示

`latest` タグを避け、明示的なバージョンを指定：

```yaml
# ✅ 推奨: バージョン明示
image: postgres:18-alpine
image: redis:7.2-alpine

# ❌ 避ける: latestタグ
image: postgres:latest
image: redis:latest
```

### 3. Alpine版の優先

軽量で攻撃対象が少ないAlpine版を優先：

```yaml
# ✅ 推奨: Alpine版
image: postgres:18-alpine
image: node:20-alpine

# ⚠️ 必要な場合のみ: full版
image: postgres:18
```

## ログ管理

### 1. ログローテーション

ディスク使用量を制限：

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"    # 1ファイルの最大サイズ
    max-file: "3"      # 保持するファイル数
```

### 2. 機密情報のログ出力防止

パスワードやトークンをログに出力しない：

```bash
# ❌ 避ける: パスワードをログに出力
echo "Connecting with password: $POSTGRES_PASSWORD"

# ✅ 推奨: パスワードは出力しない
echo "Connecting to database..."
```

## バックアップセキュリティ

### 1. バックアップファイルの保護

バックアップファイルも機密情報として扱う：

```bash
# バックアップファイルのパーミッション制限
chmod 600 backup.sql

# .gitignore に追加
echo "*.sql" >> .gitignore
echo "backup/" >> .gitignore
```

### 2. 暗号化バックアップ

重要なデータは暗号化してバックアップ：

```bash
# GPGで暗号化
pg_dump dbname | gpg --encrypt --recipient your@email.com > backup.sql.gpg

# 復号化
gpg --decrypt backup.sql.gpg | psql dbname
```

## リソース制限

### 1. DoS攻撃対策

リソース制限を設定：

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'          # CPU制限
      memory: 2G           # メモリ制限
      pids: 100            # プロセス数制限
    reservations:
      cpus: '0.5'
      memory: 512M
```

### 2. 接続数制限

データベースの最大接続数を制限：

```yaml
# PostgreSQL
environment:
  POSTGRES_MAX_CONNECTIONS: "100"

# MySQL
command: --max-connections=100
```

## ヘルスチェック

コンテナの異常を早期検出：

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
  interval: 10s       # チェック間隔
  timeout: 5s         # タイムアウト
  retries: 5          # リトライ回数
  start_period: 30s   # 起動猶予期間
```

## 定期的なメンテナンス

### 1. イメージの更新

定期的にイメージを最新版に更新：

```bash
# イメージの更新確認
docker compose pull

# 更新があれば再起動
docker compose up -d
```

### 2. 脆弱性スキャン

Docker Scoutで脆弱性をチェック：

```bash
# イメージのスキャン
docker scout cves postgres:18-alpine

# 修正版の確認
docker scout recommendations postgres:18-alpine
```

### 3. 未使用リソースの削除

定期的に未使用リソースを削除：

```bash
# 未使用コンテナ・イメージ・ボリューム削除
docker system prune -a --volumes

# 確認してから削除
docker system df  # ディスク使用量確認
```

## セキュリティチェックリスト

新しいテンプレート追加・修正時に確認：

### 機密情報管理
- [ ] すべてのパスワード・キーは環境変数化
- [ ] `.env` が `.gitignore` に追加されている
- [ ] `.env.example` に実際の値が含まれていない
- [ ] 強力なパスワードを推奨（12文字以上）

### ネットワークセキュリティ
- [ ] 不要なポートを公開していない
- [ ] ポートはローカルホストにバインド（開発環境）
- [ ] 内部ネットワークは `internal: true`

### コンテナセキュリティ
- [ ] 公式イメージを使用
- [ ] イメージタグを明示（`latest` を避ける）
- [ ] Alpine版を優先
- [ ] 設定ファイルは読み取り専用マウント

### リソース管理
- [ ] リソース制限を設定
- [ ] ログローテーション設定
- [ ] ヘルスチェック設定

### バックアップ
- [ ] バックアップファイルを `.gitignore` に追加
- [ ] バックアップのパーミッション制限

## 参考リンク

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [OWASP Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
