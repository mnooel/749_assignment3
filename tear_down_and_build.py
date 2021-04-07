# tear_down_and_build.py

from engine import OracleConnection
from drop_tables import drop_tables
from create_tables import create_tables
from create_views import create_views
from insert_data import insert_csv_data_into_oracle


if __name__ == '__main__':
    conn = OracleConnection()
    drop_tables(connection=conn)
    create_tables(connection=conn)
    create_views(connection=conn)
    tables_list = ['Branch', 'Staff', 'ActorDirector', 'DVD', 'DVDCopy', 'Makes']
    insert_csv_data_into_oracle(connection=conn, tables=tables_list)
