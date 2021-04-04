# engine.py
import os
from datetime import date
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
        self.cursor = self.conn.cursor()

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}'


class RecordValue:

    def __init__(self, key: str, value):
        self.key: str = key
        self.value = value

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}: {self.key} = {self.value}'

    def render_value_insert_string(self):
        if isinstance(self.value, str):
            return repr(self.value)
        elif isinstance(self.value, int):
            return str(self.value)
        elif isinstance(self.value, float):
            return str(self.value)
        elif isinstance(self.value, date):
            return f"(TO_DATE('{str(self.value)}', 'yyyy-mm-dd'))"
        elif self.value is None:
            return "Null"
        else:
            print(f'Error: render_value type not defined')


class Record:

    def __init__(self, table_name: str, **kwargs):
        self.table_name: str = table_name
        for key, value in kwargs.items():
            self.__setattr__(key, RecordValue(key=key, value=value))

    def __repr__(self) -> str:
        return f'{self.table_name}'

    def render_insert_string(self) -> str:
        render_dict = self.__dict__.copy()
        render_dict.pop('table_name')
        field_name_list: list = []
        values_list: list = []
        for key, value in render_dict.items():
            field_name_list.append(key)
            values_list.append(value.render_value_insert_string())
        insert_string = (
            f"INSERT INTO {self.table_name} ({', '.join(field_name_list)}) VALUES ({', '.join(values_list)})"
        )
        return insert_string
