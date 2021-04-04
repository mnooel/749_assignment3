# zip_codes.py

import pandas as pd

zips_df = pd.read_csv('external_data/uszips.csv')

states = zips_df['states'].unique()