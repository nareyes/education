import pandas as pd
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/api/v1/<station>/<date>')
def about(station, date):
    filename = f'data/TG_STAID{str(station).zfill(6)}.txt'
    df = pd.read_csv(filename, skiprows = 20, parse_dates = ['    DATE'])
    temp = df.loc[df['    DATE'] == date]['   TG'].squeeze() / 10

    return {
        'station': station,
        'date': date,
        'temperature': temp
    }

if __name__ == '__main__':
    app.run(debug = True, port = 5000)