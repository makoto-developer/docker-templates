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

```sql
-- データベースを作成
create database test_db;

-- データベースを削除
DROP DATABASE [database];

-- データベースに入る(切り替える)
use test_db;

-- データベース一覧
show databases;

-- テーブル一覧
show tables;

-- より詳しい情報を知りたい場合はこちら
show table status;

-- テーブルのDDLを確認
desc table_name

-- もっと詳しく
SHOW FULL COLUMNS FROM table_name;

-- テーブルを作成
CREATE TABLE `m_users` (
   `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "ID",
   `user_name` VARCHAR(100) NOT NULL COMMENT "ユーザー名",
   `mail_address` VARCHAR(200) NOT NULL COMMENT "メールアドレス",
   `password` VARCHAR(100) NOT NULL COMMENT "パスワード",
   `created` datetime DEFAULT NULL COMMENT "登録日",
   `modified` datetime DEFAULT NULL COMMENT "更新日"
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- テーブルを削除
DROP TABLEtable_name 

-- もっと安全に
DROP TABLE IF EXISTStable_name 

-- 
ALTER TABLE [旧テーブル名] RENAME [新テーブル名]

-- テーブルを変更(カラムを追加)
ALTER TABLE users ADD tel int DEFAULT NULL COMMENT "電話番号"  AFTER mail_address

テーブルを変更(カラムを削除)

-- レコードを追加
INSERT INTO table_name [フィールド名] VALUES [値]

-- レコードを更新
UPDATE m_users SET user_name="Qii Takao", mail_address="qiitakao@hoge.com" WHERE id = 5;__

-- レコードを削除
DELETE FROM table_name WHERE [条件式]

-- トランザクション
START TRANSACTION;
COMMIT;

-- 取り消したい時は
ROLLBACK;

```

##  管理者作業


```sql
-- データベースからログアウト
\q
## 管理者作業

-- ユーザー一覧
SELECT Host, User, Password FROM mysql.user;

-- ユーザーの追加
create user `testuser`@`localhost` IDENTIFIED BY 'password';

-- ユーザーにDB操作権限を付与
grant all privileges on test_db.* to testuser@localhost IDENTIFIED BY 'password';

-- ユーザの権限を確認
SHOW GRANTS FOR 'ユーザ名'@'ホスト名';

-- ログイン中のユーザーのパスワードを設定
set password = password('new_mysql_password');

-- 特定のユーザのパスワードを設定
set password for 'testuser'@'localhost' = password('hogehoge123');

-- 全てのデータベースからダンプを取得
mysqldump -u [ユーザー名] -p -x --all-databases > [出力ファイル名]

-- 特定のデータベースをダンプ
mysqldump -u [ユーザー名] -p -x test_db > [出力ファイル名]

-- 特定のテーブルをダンプ
mysqldump -u [ユーザー名] -p -x test_db users > [出力ファイル名]

-- ダンプする時に条件をつける
mysqldump -u [ユーザー名] -p -x test_db users --where="id < 5" > [出力ファイル名]

-- ダンプしたファイルからレコードをインポート
mysql -u[ユーザー名] -p new_db < [ダンプファイル名]

-- 実行結果を出力する方法2
SELECT * FROM table_name INTO OUTFILE '[出力先ファイルパス]';

-- 出力したダンプからテーブルを生成
LOAD DATA INFILE '[入力元ファイル名]' INTO TABLE table_name;
```

## 便利技集

```sql
-- 特定のカラムを持つテーブルを探す
SELECT table_name, column_name FROM information_schema.columns WHERE column_name = '探したいカラム名';

-- SQLの実行結果をファイルに取得
mysql -uroot -p -e "select * from users" test_db > /tmp/mysql.txt
```
