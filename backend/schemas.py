from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional

# カラコン登録用のルール 
# スマホから「登録して」と送られてくるときのデータ型
class ContactCreate(BaseModel):
    brand_name: str
    color_name: str
    dia: Optional[float] = None          # Optional は「空っぽでもOK」という意味です
    graphic_dia: Optional[float] = None
    base_curve: Optional[float] = None

# スマホに「登録完了したよ」と返すときのデータ型
class ContactResponse(ContactCreate):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True # データベースの形式を、FastAPIの形式に自動変換するおまじない


# 装着記録用のルール 

class WearLogCreate(BaseModel):
    contact_id: int
    wear_date: date
    image_path: str

class WearLogResponse(WearLogCreate):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True