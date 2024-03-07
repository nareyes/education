import smtplib, ssl
import os


def send_email(user_message):
    host = 'smtp.gmail.com'
    port = 465

    username = 'nreyes0985@gmail.com'
    password = os.getenv('PASSWORD')

    receiver = 'nreyes0985@gmail.com'

    ssl_context = ssl.create_default_context()

    with smtplib.SMTP_SSL(host, port, context = ssl_context) as server:
        server.login(username, password)
        server.sendmail(username, receiver, user_message)