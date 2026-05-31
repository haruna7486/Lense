from sqlalchemy import Column, Integer, String, Numeric, DateTime, Date, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base

# カラコン登録テーブルのモデル
class ContactMaster(Base):
    __tablename__ = "contacts_master" # 実際のデータベースのテーブル名

    id = Column(Integer, primary_key=True, index=True)
    brand_name = Column(String(100), nullable=False)  # ブランド名
    color_name = Column(String(100), nullable=False)  # カラー名
    dia = Column(Numeric(4, 2))                       # レンズ直径
    graphic_dia = Column(Numeric(4, 2))               # 着色直径
    base_curve = Column(Numeric(3, 1))                # ベースカーブ
    created_at = Column(DateTime, server_default=func.now()) # 登録日時

    # このカラコンに紐づく装着記録を簡単に引っ張ってこれるようにする設定
    wear_logs = relationship("WearLog", back_populates="contact")


# 装着記録テーブルのモデル
class WearLog(Base):
    __tablename__ = "wear_logs" # 実際のデータベースのテーブル名

    id = Column(Integer, primary_key=True, index=True)
    contact_id = Column(Integer, ForeignKey("contacts_master.id"), nullable=False) # 紐づくカラコンのID
    
    # ※今のFlutter画面には日付入力がないので、とりあえず空っぽ(null)でもOKな設定にしています
    wear_date = Column(Date, nullable=True)          
    
    memo = Column(String, nullable=True)              # 👈 追加：着け心地などのメモ
    image_path = Column(String, nullable=True)        # 写真の保存先パス
    created_at = Column(DateTime, server_default=func.now()) # 記録日時

    # この装着記録から、着けているカラコンの詳細を簡単に引っ張れるようにする設定
    contact = relationship("ContactMaster", back_populates="wear_logs")