# MySQL

MySQL9対応

## 導入手順

# `.env`を作成

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

MySQLから脱出

```shell
\q
```

## 基本技

公式サイトを見るのが一番正解 -> https://dev.mysql.com/doc/refman/8.4/en/sql-statements.html

データベース操作

```sql
-- データベースを作成
CREATE DATABASE test_db;

-- データベースを削除
DROP DATABASE [database];

-- データベースに入る(切り替える)
USE test_db;

-- データベース一覧
SHOW DATABASES;
```

テーブル操作

```sql
-- テーブル一覧
SHOW TABLES;

-- より詳しい情報を知りたい場合はこちら
SHOW TABLE STATUS;

-- テーブルのDDLを確認
DESC table_name

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
```

インデクス操作

```sql
-- インデクス作成
CREATE INDEX part_of_name ON customer (name(10));
```

Viewを作成
```shell
CREATE VIEW v_today (today) AS SELECT CURRENT_DATE;
```

データをいじる

```sql
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

プロシージャ(よく使うSQL処理を「関数」のように名前を付けて保存できる)

公式サイトの説明から実際のテーブルとデータを作ってみる -> https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html

```sql

-- データベースの作成
CREATE DATABASE IF NOT EXISTS world;
USE world;

-- city テーブルの作成
CREATE TABLE IF NOT EXISTS city (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(35) NOT NULL,
    CountryCode CHAR(3) NOT NULL,
    District VARCHAR(50) NOT NULL,
    Population INT NOT NULL
);

-- サンプルデータの挿入
INSERT INTO city (Name, CountryCode, District, Population) VALUES
('Tokyo', 'JPN', 'Tokyo-to', 7980230),
('Yokohama', 'JPN', 'Kanagawa', 3339594),
('Osaka', 'JPN', 'Osaka', 2595674),
('Nagoya', 'JPN', 'Aichi', 2154376),
('Sapporo', 'JPN', 'Hokkaido', 1790886),
('Kobe', 'JPN', 'Hyogo', 1425139),
('Kyoto', 'JPN', 'Kyoto', 1461974),
('Fukuoka', 'JPN', 'Fukuoka', 1308379),
('New York', 'USA', 'New York', 8008278),
('Los Angeles', 'USA', 'California', 3694820),
('Chicago', 'USA', 'Illinois', 2896016),
('Houston', 'USA', 'Texas', 1953631),
('Philadelphia', 'USA', 'Pennsylvania', 1517550),
('London', 'GBR', 'England', 7285000),
('Birmingham', 'GBR', 'England', 970892),
('Liverpool', 'GBR', 'England', 468945),
('Paris', 'FRA', 'Île-de-France', 2125246),
('Marseille', 'FRA', 'Provence-Alpes-Côte d''Azur', 798430),
('Lyon', 'FRA', 'Rhône-Alpes', 445452);

-- ストアドプロシージャの作成例
DELIMITER //

CREATE PROCEDURE citycount (IN country CHAR(3), OUT cities INT)
BEGIN
    SELECT COUNT(*) INTO cities
    FROM city
    WHERE CountryCode = country;
END //

DELIMITER ;

-- ストアドプロシージャの使用例(日本の都市の数を調べる)
CALL citycount('JPN', @cities);
SELECT @cities;
```

##  管理者作業


```sql
-- ユーザー一覧
SELECT Host, User, Password FROM mysql.user;

-- ユーザーの追加
CREATE USER `Testuser`@`localhost` IDENTIFIED BY 'password';

-- ユーザーにDB操作権限を付与
GRANT ALL PRIVILEGES ON test_db.* TO testuser@localhost IDENTIFIED BY 'password';

-- ユーザの権限を確認
SHOW GRANTS FOR 'ユーザ名'@'ホスト名';

-- ログイン中のユーザーのパスワードを設定
SET PASSWORD = PASSWORD('new_mysql_password');

-- 特定のユーザのパスワードを設定
SET PASSWORD FOR 'testuser'@'localhost' = PASSWORD('hogehoge123');

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
