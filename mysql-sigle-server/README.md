# MySQL

MySQL9対応

## 導入手順

`.env`を作成

```shell
cp .env.example .env
```

`.env`ファイルを開き、シークレット情報を更新する(パスワードは複雑なものに更新すること!)

```shell
vi .env
```

MySQLコンテナを立ち上げる

```shell
docker compose up -d
```

コンテナに入る

```shell

docker exec -it mysql_single_docker bash
```

MySQLにログイン

```shell
mysql -uroot -p
```

## 基本技

データベースを作成

```mysql
create database test_db;
```

データベースに入る(スイッチ)

```mysql
use test_db;
```

データベース一覧

```mysql
show databases;
```

テーブル一覧

```mysql
show tables;

-- より詳しい情報を知りたい場合はこちら
show table status;
```


テーブルのDDLを確認

```mysql
desc [テーブル名]

-- もっと詳しく
SHOW FULL COLUMNS FROM [テーブル名];
```

テーブルを作成

```mysql
CREATE TABLE `m_users` (
   `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "ID",
   `user_name` VARCHAR(100) NOT NULL COMMENT "ユーザー名",
   `mail_address` VARCHAR(200) NOT NULL COMMENT "メールアドレス",
   `password` VARCHAR(100) NOT NULL COMMENT "パスワード",
   `created` datetime DEFAULT NULL COMMENT "登録日",
   `modified` datetime DEFAULT NULL COMMENT "更新日"
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

テーブルを削除


```mysql
DROP TABLE [テーブル名]

-- もっと安全に
DROP TABLE IF EXISTS [テーブル名]
```

テーブル名を変更
```mysql
ALTER TABLE [旧テーブル名] RENAME [新テーブル名]
```
テーブルを変更(カラムを追加)

```mysql
ALTER TABLE users ADD tel int DEFAULT NULL COMMENT "電話番号"  AFTER mail_address
```

テーブルを変更(カラムを削除)

レコードを追加

```mysql
INSERT INTO [テーブル名] [フィールド名] VALUES [値]
```

レコードを更新

```mysql
UPDATE m_users SET user_name="Qii Takao", mail_address="qiitakao@hoge.com" WHERE id = 5;__
```

レコードを削除

```mysql
DELETE FROM [テーブル名] WHERE [条件式]
```

トランザクション

```mysql
START TRANSACTION;
COMMIT;
-- 取り消したい時は
ROLLBACK;
```

xxxxxxxxxxxxxxxxxxxxxxxxxxx

```mysql

```

##  MySQLよく使うコマンド集(ターミナル編)

データベースにアクセス

データベースからログアウト

```mysql
\q
```
## 管理者作業

ユーザー一覧

```myql
SELECT Host, User, Password FROM mysql.user;
```
ユーザーの追加

```mysql
create user `testuser`@`localhost` IDENTIFIED BY 'password';
```

ユーザーにDB操作権限を付与

```mysql
grant all privileges on test_db.* to testuser@localhost IDENTIFIED BY 'password';
```

ログイン中のユーザーのパスワードを設定

```mysql
set password = password('new_mysql_password');
```

特定のユーザのパスワードを設定

```mysql
set password for 'testuser'@'localhost' = password('hogehoge123');
```

全てのデータベースからダンプを取得

```mysql
mysqldump -u [ユーザー名] -p -x --all-databases > [出力ファイル名]
```

特定のデータベースをダンプ

```mysql
mysqldump -u [ユーザー名] -p -x test_db > [出力ファイル名]
```

特定のテーブルをダンプ

```mysql
mysqldump -u [ユーザー名] -p -x test_db users > [出力ファイル名]
```

ダンプする時に条件をつける

```mysql
mysqldump -u [ユーザー名] -p -x test_db users --where="id < 5" > [出力ファイル名]
```

ダンプしたファイルからレコードをインポート

```mysql
mysql -u[ユーザー名] -p new_db < [ダンプファイル名]
```

## 便利技集

特定のカラムを持つテーブルを探す

```mysql
SELECT table_name, column_name FROM information_schema.columns WHERE column_name = '探したいカラム名';
```

SQLの実行結果をファイルに取得

```mysql
mysql -uroot -p -e "select * from users" test_db > /tmp/mysql.txt
```
