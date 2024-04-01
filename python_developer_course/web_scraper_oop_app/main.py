import time
import sqlite3
import requests as req
import smtplib, ssl
import selectorlib as sel


url = 'http://programmer100.pythonanywhere.com/tours/'


class Event:

    def scrape(self, url):
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


    def extract(self, source):
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


class Data:

    def __init__(self):
        self.connection = sqlite3.connect('data.db')
    

    def read_txt(self, extracted):
        """
        Read data from a text file.

        Args:
            extracted (str): Extracted data.

        Returns:
            str: Content of the text file.
        """
        with open('data.txt', 'r') as file:
            return file.read()
        

    def read_sql(self, extracted):
        """
        Read data from an SQLite database.

        Args:
            extracted (str): Extracted data.

        Returns:
            list: A list of tuples containing the result set.
        """
        row = extracted.split(',')
        row = [item.strip() for item in row]

        cursor = self.connection.cursor()
        cursor.execute('select * from tour_events')
        result = cursor.fetchall()
        
        return result


    def store_txt(self, extracted):
        """
        Store data into a text file.

        Args:
            extracted (str): Extracted data.
        """
        with open('data.txt', 'a') as file:
            file.write(extracted + '\n')


    def store_sql(self, extracted):
        """
        Store data into an SQLite database.

        Args:
            extracted (str): Extracted data.
        """
        row = extracted.split(',')
        row = [item.strip() for item in row]

        cursor = self.connection.cursor()
        cursor.execute('''insert into tour_events values (?,?,?)''', row)
        self.connection.commit()


class Email:
    def send_email(self, message):
        """
        Send an email using SMTP with SSL.

        Args:
            message (str): The message content to be sent in the email.
        """
        host = "smtp.gmail.com"
        port = 465

        username = ''
        password = ''

        receiver = ''
        context = ssl.create_default_context()

        with smtplib.SMTP_SSL(host, port, context=context) as server:
            server.login(username, password)
            server.sendmail(username, receiver, message)


if __name__ == '__main__':
    while True:
        event = Event()
        data = Data()
        email = Email()

        scraped = event.scrape(url)
        extracted = event.extract(scraped)
        content = data.read_txt(extracted)
        print(extracted)

        if extracted != 'No upcoming tours':
            if extracted not in content:
                data.store_txt(extracted)

                # email.send_email(message = '')
                print('Email Sent')
        
        if extracted != 'No upcoming tours':
            row = data.read_sql(extracted)
            if extracted not in content:
                data.store_sql(extracted)

                print('Record Stored')
        
        time.sleep(2)