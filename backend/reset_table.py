from database import engine
from models import WearLog, Base

# wear_logsテーブルだけを一度削除する
WearLog.__table__.drop(engine, checkfirst=True)

# 最新の設計図（memo入り）でテーブルを作り直す
Base.metadata.create_all(engine)

print("データベースの更新が完了しました！🎉")