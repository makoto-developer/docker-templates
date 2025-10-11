-- レプリケーションユーザーの作成
CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'ChangeThisReplPassword123!';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';

-- モニタリングユーザーの作成（ProxySQL用）
CREATE USER IF NOT EXISTS 'monitor'@'%' IDENTIFIED WITH mysql_native_password BY 'monitor';
GRANT REPLICATION CLIENT ON *.* TO 'monitor'@'%';
GRANT SUPER, PROCESS ON *.* TO 'monitor'@'%';

-- アプリケーションユーザーの権限設定
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, TRIGGER 
ON world.* TO 'appuser'@'%';

-- 権限の反映
FLUSH PRIVILEGES;

-- worldデータベースの使用
USE world;

-- cityテーブルの作成
CREATE TABLE IF NOT EXISTS city (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(35) NOT NULL,
    CountryCode CHAR(3) NOT NULL,
    District VARCHAR(50) NOT NULL,
    Population INT NOT NULL,
    INDEX idx_countrycode (CountryCode),
    INDEX idx_population (Population),
    INDEX idx_name (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- ストアドプロシージャの作成
DELIMITER //

CREATE PROCEDURE citycount (IN country CHAR(3), OUT cities INT)
BEGIN
    SELECT COUNT(*) INTO cities
    FROM city
    WHERE CountryCode = country;
END //

DELIMITER ;

-- テーブル統計の更新
ANALYZE TABLE city;