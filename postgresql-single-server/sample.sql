-- 思いつきで作ったテーブルなので参考程度に
CREATE DATABASE myshop


CREATE SCHEMA online_shop;


CREATE TABLE "order"
(
    id                  BIGSERIAL
        constraint order_pk
            primary key,
    order_item_group_id BIGSERIAL,
    user_id             BIGSERIAL,
    amount              BIGSERIAL,
    amount_without_tax  BIGSERIAL,
    tax                 BIGSERIAL,
    tax_rate            NUMERIC
);

-- テーブル・カラムへのコメント設定
COMMENT ON TABLE "order" IS '注文履歴';
COMMENT ON COLUMN "order".order_item_group_id IS '商品IDのリスト';
COMMENT ON COLUMN "order".user_id IS 'ユーザID';
COMMENT ON COLUMN "order".amount IS '税込価格(商品価格の合計)';
COMMENT ON COLUMN "order".amount_without_tax IS '税抜価格(税抜の商品価格の合計)';
COMMENT ON COLUMN "order".tax IS '消費税(商品価格に対する税の合計)';
COMMENT ON COLUMN "order".tax_rate IS '消費税率';

CREATE INDEX order_user_id_index
    ON "order" (user_id);

CREATE INDEX order_order_item_group_id_index
    ON "order" (order_item_group_id);

CREATE INDEX order_user_id_order_item_group_id_index
    ON "order" (user_id, order_item_group_id);

CREATE INDEX order_user_id_id_index
    ON "order" (user_id, id);



