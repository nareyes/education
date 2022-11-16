import pandas as pd
import pickle

# load data
df = pickle.load(open('data/abc_classification_modeling.p', 'rb')) # rb is reading
df.head()