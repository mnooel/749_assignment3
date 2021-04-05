# create_tables.py
from engine import OracleConnection


def create_tables(connection: OracleConnection):

    connection.execute_scripts_from_file('sql_scripts/create_tables.sql')


if __name__ == '__main__':
    conn = OracleConnection()
    create_tables(connection=conn)
