# create_views.py
from engine import OracleConnection


def create_views(connection: OracleConnection):

    connection.execute_scripts_from_file('sql_scripts/create_views.sql')


if __name__ == '__main__':
    conn = OracleConnection()
    create_views(connection=conn)
