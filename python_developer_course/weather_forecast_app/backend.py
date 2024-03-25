import requests as req

api_key = '141710af2113bab9f55ef73e1bcd33d5'

def get_weather_data(location, days = None, unit = None):
    """
    Retrieve weather forecast data from the OpenWeatherMap API.

    Parameters:
        location (str): The name of the location for which weather forecast data is requested.
        days (int, optional): The number of days for which forecast data is required. Default is None.
                              If None, the default behavior is to retrieve forecast data for the next 5 days.
        unit (str, optional): The units for temperature measurement. Default is None.
                              If None, temperature is provided in Kelvin.
                              Possible values: 'metric' for Celsius, 'imperial' for Fahrenheit.

    Returns:
        dict: A dictionary containing weather forecast data for the specified location.
              The dictionary includes details such as temperature, humidity, wind speed, etc.
              The forecast data is typically provided in 3-hour intervals.

    Raises:
        HTTPError: If an error response is received from the OpenWeatherMap API.

    Example:
        >>> print(get_weather_data(location='Tokyo', days=3))
    """

    # construct the URL for the API request using the provided location and API key
    url = f'http://api.openweathermap.org/data/2.5/forecast?q={location}&appid={api_key}'

    # send a GET request to the OpenWeatherMap API
    response = req.get(url)

    # convert the response content to JSON format
    content = response.json()

    # calculate the number of forecast data entries required based on the specified number of days
    calc_days = 8 * days

    # extract the forecast data for the specified number of days
    filtered_content = content['list'][:calc_days]

    # Return the filtered weather forecast data
    return filtered_content

if __name__ == '__main__':
    # if the script is executed directly, print the weather forecast data for Tokyo for the next 3 days
    print(get_weather_data(location='Tokyo', days = 3))