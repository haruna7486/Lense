from fastapi import FastAPI, Depends, HTTPException, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import shutil # 👈 ファイルを保存するためのツール
import os     # 👈 フォルダを操作するためのツール

import models, schemas, database

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # どこからの通信でも許可する（テスト用設定）
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


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

# 装着記録（写真＋メモ）を受け取って保存するAPI
@app.post("/wear_logs/")
async def create_wear_log(
    contact_id: int = Form(...),
    memo: str = Form(None),
    image: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    image_path = None
    
    # もし画像が送られてきていたら、uploadsフォルダに保存する
    if image is not None:
        # 万が一uploadsフォルダがなくても自動で作る安全対策
        os.makedirs("uploads", exist_ok=True)
        
        # 保存する名前を決める（例: 1_photo.jpg）
        file_name = f"{contact_id}_{image.filename}"
        save_path = f"uploads/{file_name}"
        
        # 実際にファイルをフォルダに書き込む
        with open(save_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
            
        image_path = save_path # データベースにはこの「パス（保存場所）」を記録する

    # データベースに記録を保存
    new_log = models.WearLog(
        contact_id=contact_id,
        memo=memo,
        image_path=image_path
    )
    db.add(new_log)
    db.commit()
    db.refresh(new_log)

    return {"message": "記録の保存に成功しました！", "log_id": new_log.id}
