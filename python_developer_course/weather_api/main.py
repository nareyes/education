import pandas as pd
from flask import Flask, render_template

app = Flask(__name__)


# read the station data from a CSV file
stations_df = pd.read_csv('data/stations.txt', skiprows = 17)


@app.route('/')
def home():
    """
    Renders the home page with a table of station data.

    Returns:
        str: HTML page containing the table of station data.
    """

    return render_template('home.html', stations_table = stations_df.to_html())


@app.route('/api/v1/<station>/<date>')
def about(station, date):
    """
    Provides information about temperature at a specific station on a given date.

    Parameters:
        station (str): Station ID.
        date (str): Date in 'YYYY-MM-DD' format.

    Returns:
        dict: JSON object containing station ID, date, and temperature.
    """

    filename = f'data/TG_STAID{str(station).zfill(6)}.txt'
    df = pd.read_csv(filename, skiprows = 20, parse_dates = ['    DATE'])
    temp = df.loc[df['    DATE'] == date]['   TG'].squeeze() / 10

    return {
        'station_id': station,
        'date': date,
        'temp_c': temp
    }


@app.route('/api/v1/<station>')
def all_data(station):
    """
    Provides all temperature data for a specific station.

    Parameters:
        station (str): Station ID.

    Returns:
        list: List of dictionaries containing station ID, date, and temperature.
    """

    filename = f'data/TG_STAID{str(station).zfill(6)}.txt'
    df = pd.read_csv(filename, skiprows = 20, parse_dates = ['    DATE'])
    df = df[['STAID', '    DATE', '   TG']]
    df.columns = ['station_id', 'date', 'temp_c']
    df['temp_c'] = df['temp_c'] / 10

    result = df.to_dict(orient='records')

    return result


@app.route('/api/v1/annual/<station>/<year>')
def annual_data(station, year):
    """
    Provides annual temperature data for a specific station and year.

    Parameters:
        station (str): Station ID.
        year (str): Year in 'YYYY' format.

    Returns:
        list: List of dictionaries containing station ID, date, and temperature for the specified year.
    """

    filename = f'data/TG_STAID{str(station).zfill(6)}.txt'
    df = pd.read_csv(filename, skiprows = 20)
    df = df[['STAID', '    DATE', '   TG']]
    df.columns = ['station_id', 'date', 'temp_c']
    df['temp_c'] = df['temp_c'] / 10
    df['date'] = df['date'].astype(str)

    result = df[df['date'].str.startswith(str(year))].to_dict(orient = 'records')

    return result


# run the Flask application
if __name__ == '__main__':
    app.run(debug = True, port = 5000)