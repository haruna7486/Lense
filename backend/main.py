from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models, schemas, database

app = FastAPI()

# 依存性の注入
# データベースへの接続窓口（セッション）を自動で開き、作業が終わったら自動で閉じてくれる便利な仕組み
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ホーム画面（生存確認用）
@app.get("/")
def read_root():
    return {"message": "LenseLog API with PostgreSQL is running!"}


# カラコンを登録する機能（API） 
@app.post("/contacts/", response_model=schemas.ContactResponse)
def create_contact(contact: schemas.ContactCreate, db: Session = Depends(get_db)):
    # スキーマを通ったデータを、モデルに変換してデータベースに送る準備をする
    db_contact = models.ContactMaster(
        brand_name=contact.brand_name,
        color_name=contact.color_name,
        dia=contact.dia,
        graphic_dia=contact.graphic_dia,
        base_curve=contact.base_curve
    )
    db.add(db_contact) # データベースに追加
    db.commit()        # 変更をセーブする
    db.refresh(db_contact) # データベースで自動生成されたIDや日時を反映する
    return db_contact


# 登録されているカラコン一覧を取得する機能（API） 
@app.get("/contacts/", response_model=List[schemas.ContactResponse])
def read_contacts(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # データベースの「contacts_master」テーブルからデータを最大100件取ってくる
    contacts = db.query(models.ContactMaster).offset(skip).limit(limit).all()
    return contacts

