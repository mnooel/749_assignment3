# insert_data.py

import pandas as pd

from engine import OracleEngine, Record


def insert_csv_data_into_oracle(tables_list: list):
    # engine
    engine = OracleEngine()

    for table in tables_list:

        # data df
        data_df = pd.read_csv(f'external_data/{table}.csv')
        data_df = data_df.where(pd.notnull(data_df), None)

        record_objects = []

        for record in data_df.to_dict(orient='records'):
            record_objects.append(Record(table_name=table, **record))

        for record in record_objects:
            insert_string = record.render_insert_string()
            print(insert_string)
            engine.cursor.execute(insert_string)

    engine.conn.commit()


if __name__ == '__main__':
    tables_list = ['Branch', 'Staff', 'ActorDirector', 'DVD', 'DVDCopy', 'Makes']
    insert_csv_data_into_oracle(tables_list=tables_list)
