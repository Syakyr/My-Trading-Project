import numpy as np
import pandas as pd

_file = 'GBPUSD - 1-1-16 - 11-30-16 Tick.csv'
tick_data = pd.read_csv(_file)

print(tick_data.head())