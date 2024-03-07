"""
This script defines a Streamlit web application to showcase projects and a short biography.

Instructions:
    - Activate the Conda environment with the command: conda activate py_sandbox
    - Run the Streamlit app with the command: streamlit run Home.py

Dependencies:
    - pandas: for data manipulation and analysis.
    - streamlit: for creating interactive web applications.

Usage:
    - This script serves as the main entry point for launching the Streamlit web application.
    - Upon execution, it displays a web page with a profile picture, a short biography, and a list of projects.

Notes:
    - Ensure that the 'images' directory contains the 'profile.png' image and images corresponding to each project.
    - The data file 'data.csv' should be located in the same directory as this script and must be in CSV format with
      columns 'app', 'description', 'image', and 'url'.
    - Run Streamlit app with command: streamlit run <filename>
"""

import pandas as pd
import streamlit as st


# configure page layout
st.set_page_config(layout = 'wide')


# define columns for profile picture and biography
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


# read project data from csv
df = pd.read_csv('data.csv', sep = ';')
df = df.sort_values(by = ['app'])


# define columns for project information
col3, empty_col, col4 = st.columns([1.5, 0.5, 1.5])

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