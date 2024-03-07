# activate conda env with command: conda activate py_sandbox
# run Streamlit app with command: streamlit run Home.py

import pandas as pd
import streamlit as st


st.set_page_config(layout = 'wide')

col1, col2 = st.columns(2)

with col1:
    st.image('images/profile.png', width = 600)

with col2:
    name = 'Nick Reyes'
    biography = '''
    Hi, I'm Nick! I'm learning Python and this site serves as a project to learn simple 
    website design while showcasing the projects I worked on during a Python Developer course.
    I currently work as a Data Engineer and am taking this course to learn Software Engineering
    principles with Python.
    '''
    st.title(name)
    st.info(biography)

col3, empty_col, col4 = st.columns([1.5, 0.5, 1.5])
df = pd.read_csv('data.csv', sep = ';')
df = df.sort_values(by = ['app'])

with col3:
    for index, row in df[:10].iterrows():
        st.header(row['app'])
        st.text(row['description'])
        st.image('images/' + row['image'], width = 300)
        st.write(f'[Source Code]({row["url"]})')

with col4:
    for index, row in df[10:].iterrows():
        st.header(row['app'])
        st.text(row['description'])
        st.image('images/' + row['image'], width = 300)
        st.write(f'[Source Code]({row["url"]})')