"""
Function to send an email using SMTP with SSL.

This function sends an email using SMTP (Simple Mail Transfer Protocol) with SSL encryption. It requires the `smtplib` and `ssl` modules.

Parameters:
    message (str): The message content to be sent in the email.

Variables:
    host (str): The SMTP server hostname. For Gmail, it's "smtp.gmail.com".
    port (int): The port number for the SMTP server. For SSL, it's usually 465.
    username (str): The email address used for authentication.
    password (str): The password for the email account.
    receiver (str): The email address of the recipient.
    context (ssl.SSLContext): SSL context used for establishing a secure connection.

Returns:
    None. The function sends the email but does not return any value.

Note:
    - Ensure that the `username` and `password` variables are properly configured with your email credentials.
    - Make sure to enable less secure app access or generate an app password for your Gmail account if you're using Gmail.
"""


import smtplib, ssl


def send_email(message):
    host = "smtp.gmail.com"
    port = 465

    username = ''
    password = ''

    receiver = ''
    context = ssl.create_default_context()

    with smtplib.SMTP_SSL(host, port, context=context) as server:
        server.login(username, password)
        server.sendmail(username, receiver, message)