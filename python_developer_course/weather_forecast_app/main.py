import streamlit as st

# app layout
st.title('Weather Forecast App')
location = st.text_input('Location: ')
days = st.slider('Number of Days', min_value = 1, max_value = 5)
option = st.selectbox('Select View', ('Graph', 'Daily'))
st.divider()
st.header(f'{option} Forecast')
st.subheader(f'Location: {location}')
st.subheader(f'Number of Days: {days}')