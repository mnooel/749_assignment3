# drop_tables.py
from engine import OracleConnection


def drop_tables(connection: OracleConnection):

    connection.execute_scripts_from_file('sql_scripts/drop_tables.sql')


if __name__ == '__main__':
    conn = OracleConnection()
    drop_tables(connection=conn)
