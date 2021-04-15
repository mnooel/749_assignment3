# engine.py
import os
import logging
import re
from datetime import date
from dotenv import load_dotenv
import cx_Oracle

from setup_logging import setup_logger

sql_logger = logging.getLogger(__name__)
setup_logger(sql_logger, 'logs/oracle.log')

load_dotenv()


class OracleConnection(cx_Oracle.Connection):

    def __init__(self):
        connectString = (
            f'{os.getenv("ORACLE_USER")}/{os.getenv("ORACLE_PASSWORD")}@{os.getenv("ORACLE_DSN")}'
        )
        cx_Oracle.init_oracle_client(lib_dir='/Users/michaelnoel/Downloads/instantclient_19_8')
        sql_logger.info('Connected to the database.')
        super().__init__(connectString)

    def execute(self, sql):
        cursor = self.cursor()
        try:
            # sql_logger.info(sql)
            cursor.execute(sql)
            sql_logger.info(sql)
            # return cursor
        except cx_Oracle.Error as e:
            errorObj, = e.args
            sql_logger.error(f'{errorObj.message} | {sql}')

    def execute_scripts_from_file(self, path: str):

        # sql command list to append to
        sql_commands: list = []

        # open and read the file as a single buffer
        sql_file = open(path, 'r')
        sql_lines = sql_file.readlines()
        sql_file.close()

        # blank string to append parts of commands to
        command = ''
        procedure = False

        # iterate over lines to create commands
        for line in sql_lines:

            # strip leading whitespace off the line
            line = line.lstrip()

            # ignore line if the line is a comment pass
            if '--' == line[:2]:
                pass
                continue

            # aggregate lines that are part of P/L language
            if 'CREATE OR REPLACE PROCEDURE' in line or \
                    'CREATE OR REPLACE TRIGGER' in line or \
                    'CREATE OR REPLACE FUNCTION' in line:
                procedure = True

            if procedure:
                # ignore line if the line is a comment
                if '--' == line[:2]:
                    pass
                # ignore line if the line is whitespace
                elif '\n' == line:
                    pass
                # if end of command
                #   1. finish create the command
                #   2. append it to the list of commands
                #   3. clear the command string for the next command
                #   4. set procedure back to false
                elif 'END;/\n' in line:
                    # replace new line characters
                    line = line.replace('/\n', ' ')
                    # replace excess whitespace
                    line = re.sub(' +', ' ', line)
                    command += line
                    sql_commands.append(command)
                    command = ''
                    procedure = False
                    continue
                # line is middle part of P/L command
                else:
                    # replace new line characters
                    line = line.replace('\n', ' ')
                    # replace excess whitespace
                    line = re.sub(' +', ' ', line)
                    command += line
                    continue
            # ignore line if the line is whitespace
            elif '\n' == line:
                pass
            else:
                # replace new line characters
                line = line.replace('\n', ' ')
                # replace excess whitespace
                line = re.sub(' +', ' ', line)
                # if end of command
                #   1. finish create the command
                #   2. append it to the list of commands
                #   3. clear the command string for the next command
                if ';' in line:
                    line = line.replace(';', '')
                    command += line
                    sql_commands.append(command)
                    command = ''
                # line is part of previous line command. add it to the partial command string.
                else:
                    command += line

        # execute every command from the file
        for command in sql_commands:
            self.execute(command)


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
