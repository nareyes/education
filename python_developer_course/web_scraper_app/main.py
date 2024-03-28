import time
import requests as req
import selectorlib as sel
from send_email import send_email

url = 'http://programmer100.pythonanywhere.com/tours/'
headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}


def scrape(url):
    response = req.get(url, headers)
    source = response.text

    return source


def extract(source):
    extractor = sel.Extractor.from_yaml_file('extract.yaml')
    value = extractor.extract(source)['tours']

    return value


def read(extracted):
    with open('data.txt', 'r') as file:
        return file.read()
    

def store(extracted):
    if extracted != 'No upcoming tours':
        with open('data.txt', 'a') as file:
            file.write(extracted + '\n')


if __name__ == '__main__':
    while True:
        scraped = scrape(url)
        extracted = extract(scraped)
        content = read(extracted)
        print(extracted)

        if extracted != 'No upcoming tours':
            if extracted not in content:
                store(extracted)

                # send_email(message = '')
                print('Email Sent')
        
        time.sleep(2)