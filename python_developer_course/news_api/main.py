"""
Script to fetch top headlines from TechCrunch using the News API and send them via email.

This script makes use of the News API to retrieve the top headlines from TechCrunch and then sends them via email. 
It requires the `requests` library for making HTTP requests and a custom `send_email` module for sending emails.

API Key:
    The API key for accessing the News API is stored in the `api_key` variable.

URL:
    The URL used for making the API request is stored in the `url` variable.

Functionality:
    1. Makes an HTTP GET request to the News API endpoint.
    2. Parses the JSON response to extract article titles and descriptions.
    3. Constructs an email body containing the article titles and descriptions.
    4. Encodes the email body to UTF-8.
    5. Sends the email using the `send_email` module.

Note:
    - Ensure that the `send_email` module is properly configured with your email server settings.
    - This script assumes that the `send_email` module contains a function named `send_email` that accepts a `message` parameter to send the email.
"""


import requests as req
from send_email import send_email

api_key = '35c80c376c864f5db83ef5935f99551f'
url = 'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=35c80c376c864f5db83ef5935f99551f'


# make request and store content
request = req.get(url)
content = request.json()


# extract article titles and descriptions
# for article in content['articles']:
#     print(article['title'])
#     print(article['description'])


# extract article titles and descriptions and store in body variable
body = ""
for article in content["articles"]:
    if article["title"] is not None:
        body = body + str(article["title"]) + "\n" + str(article["description"]) + 2*"\n"


# view output
# print(body)


# send email
body = body.encode("utf-8")
send_email(message=body)