from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/api/v1/<station>/<date>')
def about(station, date):
    temp = 23
    return {
        'station': station,
        'date': date,
        'temperature': temp
    }

if __name__ == '__main__':
    app.run(debug = True)