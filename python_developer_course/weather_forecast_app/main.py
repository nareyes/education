import os
import streamlit as st
import plotly.express as px
from backend import get_weather_data

# app Layout
st.title('Weather Forecast App')
location = st.text_input('Location (City):')
days = st.slider('Number of Days:', min_value = 1, max_value = 5)
unit = st.selectbox('Select Unit:', ('Celsius', 'Farenheit'))
view = st.selectbox('Select View:', ('Graph', 'Daily'))
st.divider()
st.header(f'{view} Forecast')
st.subheader(f'Location: {location}')
st.subheader(f'Number of Days: {days}')

if location:
    try:
        # call backend function to retrieve weather data
        filtered_content = get_weather_data(location, days, unit)
        print(filtered_content)

        # create dynamic views based on user selection
        if view == 'Graph':
            # extract dates and temperatures from weather data
            dates = [data['dt_txt'] for data in filtered_content]
            temps_raw = [data['main']['temp'] / 10 for data in filtered_content]

            # convert temperatures
            if unit == 'Celsius':
                temps = [data['main']['temp'] / 10 for data in filtered_content]
            elif unit == 'Farenheit':
                temps = [((data['main']['temp'] / 10) * 9/5) + 32 for data in filtered_content]

            # create a line chart using Plotly Express
            figure = px.line(
                x = dates,
                y = temps,
                labels={
                    'x': 'Date',
                    'y': f'Temperature ({unit})'
                }
            )
            st.plotly_chart(figure)
        
        elif view == 'Daily':
            # define image paths for different weather conditions
            images = {
                'Clear': 'images/clear.png',
                'Clouds': 'images/clouds.png',
                'Rain': 'images/rain.png',
                'Snow': 'images/snow.png',
            }

            # extract daily weather conditions from weather data
            daily_conditions = [data['weather'][0]['main'] for data in filtered_content]
            image_paths = [images[condition] for condition in daily_conditions]

            # display weather condition images
            st.image(image_paths, width = 115)

    except KeyError:
        st.write('Location Does Not Exist')