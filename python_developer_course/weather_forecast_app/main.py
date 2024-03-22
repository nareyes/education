import streamlit as st
import plotly.express as px

# app layout
st.title('Weather Forecast App')
location = st.text_input('Location:')
days = st.slider('Number of Days:', min_value = 1, max_value = 5)
unit = st.selectbox('Select Unit:', ('Celsius', 'Farenheit'))
option = st.selectbox('Select View:', ('Graph', 'Daily'))
st.divider()
st.header(f'{option} Forecast')
st.subheader(f'Location: {location}')
st.subheader(f'Number of Days: {days}')

# dynamic graph
def get_weather_data(days):
    dates = ['2024-03-22', '2024-03-23', '2024-03-24', '2024-03-25', '2024-03-26']
    temps = [28, 31, 30, 22, 29]
    temps = [days * i for i in temps]

    return dates, temps

dates, temps = get_weather_data(days)

figure = px.bar(
    x = dates, 
    y = temps, 
    labels = {
        'x': 'Date',
        'y': f'Temperature ({unit})'
    }
)
st.plotly_chart(figure)