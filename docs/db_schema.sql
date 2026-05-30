-- カラコン登録テーブル
CREATE TABLE contacts_master (
    id SERIAL PRIMARY KEY,            -- ID
    brand_name VARCHAR(100) NOT NULL, -- ブランド名
    color_name VARCHAR(100) NOT NULL, -- カラー名
    dia NUMERIC(4, 2),                -- レンズ直径
    graphic_dia NUMERIC(4, 2),        -- 着色直径
    base_curve NUMERIC(3, 1),         -- ベースカーブ
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 登録日時
);

-- 装着記録テーブル
CREATE TABLE wear_logs (
    id SERIAL PRIMARY KEY,            -- ID
    contact_id INTEGER NOT NULL REFERENCES contacts_master(id), -- つけたカラコンのID
    wear_date DATE NOT NULL,          -- 装着した日付
    image_path TEXT NOT NULL,         -- 写真の保存先パス
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 記録日時
);