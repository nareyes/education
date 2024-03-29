import time
import sqlite3
import requests as req
import selectorlib as sel
from send_email import send_email


# establish sql connection and cursor
connection = sqlite3.connect('data.db')
cursor = connection.cursor()


url = 'http://programmer100.pythonanywhere.com/tours/'


def scrape(url):
    """
    Scrape the provided URL and return the HTML source code.

    Args:
        url (str): The URL to scrape.

    Returns:
        str: The HTML source code of the webpage.
    """
    response = req.get(url)
    source = response.text

    return source


def extract(source):
    """
    Extract relevant data from the HTML source using a selector.

    Args:
        source (str): The HTML source code of the webpage.

    Returns:
        str: Extracted data.
    """
    extractor = sel.Extractor.from_yaml_file('extract.yaml')
    value = extractor.extract(source)['tours']

    return value


def read_txt(extracted):
    """
    Read data from a text file.

    Args:
        extracted (str): Extracted data.

    Returns:
        str: Content of the text file.
    """
    with open('data.txt', 'r') as file:
        return file.read()
    

def store_txt(extracted):
    """
    Store data into a text file.

    Args:
        extracted (str): Extracted data.
    """
    with open('data.txt', 'a') as file:
        file.write(extracted + '\n')


def read_sql(extracted):
    """
    Read data from an SQLite database.

    Args:
        extracted (str): Extracted data.

    Returns:
        list: A list of tuples containing the result set.
    """
    row = extracted.split(',')
    row = [item.strip() for item in row]

    cursor = connection.cursor()
    cursor.execute('select * from tour_events')
    result = cursor.fetchall()
    
    return result


def store_sql(extracted):
    """
    Store data into an SQLite database.

    Args:
        extracted (str): Extracted data.
    """
    row = extracted.split(',')
    row = [item.strip() for item in row]

    cursor = connection.cursor()
    cursor.execute('''insert into tour_events values (?,?,?)''', row)
    connection.commit()


if __name__ == '__main__':
    while True:
        scraped = scrape(url)
        extracted = extract(scraped)
        content = read_txt(extracted)
        print(extracted)

        if extracted != 'No upcoming tours':
            if extracted not in content:
                store_txt(extracted)

                # send_email(message = '')
                print('Email Sent')
        
        if extracted != 'No upcoming tours':
            row = read_sql(extracted)
            if extracted not in content:
                store_sql(extracted)

                print('Record Stored')
        
        time.sleep(2)