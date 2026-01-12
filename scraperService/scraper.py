import requests
from bs4 import BeautifulSoup
import json

url = "https://www.somaiya.edu/arigel_general/faculty_ajax_new/1"
print(url)
headers = {
    "User-Agent": "Mozilla/5.0",
    "X-Requested-With": "XMLHttpRequest",
    "Content-Type": "application/x-www-form-urlencoded"
}

payload = {
    "page_no": 1,
    "sortBy": "name_ASC",
    "keywords": "",
    "campus_check": "",
    "institute_check": "0,16",
    "sub_institute_check": "",
    "dept_check": "",
    "desig_check": "",
    "lang": "en"
}

faculty_mails = []

response = requests.post(url, headers=headers, data=payload)

print("Status:", response.status_code)

soup = BeautifulSoup(response.text, "lxml")
# CSS selector is safest
for a in soup.select("a.svv-link[href^='mailto:']"):
    faculty_mails.append(a["href"].replace("mailto:", ""))


data_path = "../backend/data.ts"

with open(data_path, "w",encoding="utf-8") as f:
    f.write("export const facuty_mails: string[] = ")
    json.dump(faculty_mails, f, indent=2)
    f.write(";\n")
print("Data.ts written successfully")
print(faculty_mails)

