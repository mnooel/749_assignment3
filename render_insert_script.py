# render_insert_script.py

import pandas as pd
from engine import Record


def render_insert_script(file_name: str, tables: list):

    file = open(f'sql_scripts/{file_name}', 'w')

    file.write('-- BUS-ADM 749 Data and Information Management\n')
    file.write('-- Michael Noel\n')
    file.write('-- Continental Palms DVD\n')
    file.write(f'-- {file_name}\n\n')

    for table in tables:

        file.write(f'-- Insert {table} data\n')

        # data df
        data_df = pd.read_csv(f'external_data/{table}.csv')
        data_df = data_df.where(pd.notnull(data_df), None)

        record_objects = []

        for record in data_df.to_dict(orient='records'):
            record_objects.append(Record(table_name=table, **record))

        for record in record_objects:
            file.write(record.render_insert_string() + ';\n')

        file.write('\n')

    file.close()


if __name__ == '__main__':
    tables = ['Branch', 'Staff', 'ActorDirector', 'Member', 'DVD', 'DVDCopy', 'Makes']
    render_insert_script(file_name='insert_data.sql', tables=tables)
