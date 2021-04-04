# engine.py
import os
from dotenv import load_dotenv
import cx_Oracle

load_dotenv()


class OracleEngine:

    def __init__(self):
        cx_Oracle.init_oracle_client(lib_dir='/Users/michaelnoel/Downloads/instantclient_19_8')
        self.conn: cx_Oracle.Connection = cx_Oracle.connect(
            f'{os.getenv("ORACLE_USER")}/{os.getenv("ORACLE_PASSWORD")}@{os.getenv("ORACLE_DSN")}'
        )
        print('Connected to Oracle Database')

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}'
