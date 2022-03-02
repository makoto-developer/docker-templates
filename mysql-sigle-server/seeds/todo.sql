create table todo
(
    id       int auto_increment
        primary key,
    title    varchar(10) null,
    type     int         null,
    contents longtext    null
);

INSERT INTO homestead.todo (id, title, type, contents) VALUES (1, '買い物', 0, 'たまご * 2\nにんじん');
INSERT INTO homestead.todo (id, title, type, contents) VALUES (2, '家賃支払', 1, '29日に支払い');
INSERT INTO homestead.todo (id, title, type, contents) VALUES (3, 'ごみだし', 1, '朝8:00にだす');
INSERT INTO homestead.todo (id, title, type, contents) VALUES (4, '圏論道案内を読む', 2, '今月末まで');

