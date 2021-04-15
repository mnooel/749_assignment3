# create_procedures.py
from engine import OracleConnection


def create_procedures(connection: OracleConnection):

    connection.execute_scripts_from_file('sql_scripts/create_procedures.sql')


if __name__ == '__main__':
    conn = OracleConnection()
    create_procedures(connection=conn)
