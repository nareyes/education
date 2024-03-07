import streamlit as st
from Email import send_email

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