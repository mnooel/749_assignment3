# insert_data.py

import pandas as pd
from engine import OracleConnection, Record


def insert_csv_data_into_oracle(connection: OracleConnection, tables: list):

    for table in tables:

        # data df
        data_df = pd.read_csv(f'external_data/{table}.csv')
        data_df = data_df.where(pd.notnull(data_df), None)

        record_objects = []

        for record in data_df.to_dict(orient='records'):
            record_objects.append(Record(table_name=table, **record))

        for record in record_objects:
            insert_string = record.render_insert_string()
            connection.execute(insert_string)

    connection.commit()


if __name__ == '__main__':
    conn = OracleConnection()
    tables_list = ['Branch', 'Staff', 'ActorDirector', 'DVD', 'DVDCopy', 'Makes']
    insert_csv_data_into_oracle(connection=conn, tables=tables_list)
