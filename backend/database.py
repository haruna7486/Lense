from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# データベースのURL
SQLALCHEMY_DATABASE_URL = "postgresql://localhost/lenselog"

# データベースとの接続を行う
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# セッションを作成（データベースとのやりとりを行うためのもの）
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# テーブルの設計図を作成するためのベース
Base = declarative_base()