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

title = 'Python Portfolio'
st.title(title)