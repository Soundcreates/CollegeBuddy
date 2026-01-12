import requests
from bs4 import BeautifulSoup

url = "https://www.somaiya.edu/en/contact-us/faculty-directory"
response = requests.get(url)

soup = BeautifulSoup(response.text, "html.parser")

print(soup.prettify())