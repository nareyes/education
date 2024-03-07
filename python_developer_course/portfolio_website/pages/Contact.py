"""
This Streamlit page creates a contact form for users to send emails.

Instructions:
    - Ensure that the 'Email.py' script containing the 'send_email' function is available in the same directory.
    - Execute this script to run the Streamlit web application.
    - Users can enter their email address, compose a message, and submit it using the provided form.
    - Upon submission, the message is sent to the specified email address using the 'send_email' function.

Dependencies:
    - streamlit: for creating interactive web applications.

Usage:
    - This script serves as the main entry point for launching the Streamlit web application.
    - Upon execution, it displays a header titled 'Contact Me' followed by an email form.
    - Users can input their email address and message in the respective fields.
    - After clicking the 'Submit' button, the message is sent to the specified email address.
    - A confirmation message 'Message Sent!' is displayed upon successful submission.

Note:
    - Ensure that the 'Email.py' script contains the 'send_email' function to handle email sending functionality.
"""

import streamlit as st
from Email import send_email


# create a form for users to send a message
st.header('Contact Me')

with st.form(key = 'email_form'):
    user_email = st.text_input('Enter Email')
    user_message = st.text_area('Enter Message')
    button = st.form_submit_button('Submit')

    message = f"""\
        Subject: Email From {user_email}
        From: {user_email}
        {user_message}
    """

    if button:
        send_email(user_message)
        st.info('Message Sent!')