import smtplib, ssl
import os


def send_email(user_message):
    """
    Send an email using SMTP protocol with SSL encryption.

    Parameters:
        user_message (str): The message to be sent in the email.

    Raises:
        smtplib.SMTPAuthenticationError: If authentication fails with the provided credentials.
        smtplib.SMTPException: If an error occurs during the sending process.

    Note:
        Before using this function, ensure that you have set up your Gmail account to allow less secure apps
        to access it or have generated an app password if two-factor authentication is enabled.
        Additionally, the USERNAME and PASSWORD environment variables must be set with the Gmail account's password.
    """

    host = 'smtp.gmail.com'
    port = 465

    username = os.getenv('USERNAME')
    password = os.getenv('PASSWORD')

    receiver = os.getenv('USERNAME')

    ssl_context = ssl.create_default_context()

    with smtplib.SMTP_SSL(host, port, context = ssl_context) as server:
        server.login(username, password)
        server.sendmail(username, receiver, user_message)