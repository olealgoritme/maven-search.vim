#!/usr/bin/python3
import sys
from urllib.request import urlopen
from bs4 import BeautifulSoup

# current https://mvnrepository.com/search?q=queryString
# <h2 class="im-title"><span style="font-weight: normal; font-size:90%; color:gray">1. </span><a href="/artifact/org.flywaydb/flyway-core">Flyway Core</a><a class="im-usage" href="/artifact/org.flywaydb/flyway-core/usages"><b>414</b> usages</a></h2>
_REPO = 'https://mvnrepository.com/'

def search_repo(url):
    page = urlopen(url)
    _soup = BeautifulSoup(page, 'html.parser')
    res_list = _soup.find_all('h2', class_="im-title")

    new_list = '';
    for item in res_list:
        new_list += item.span.text
        new_list += " "
        new_list += item.a.text
        new_list += " ("
        new_list += item.a['href'].replace("/artifact/", "").replace("/", ".")
        new_list += ")"
        new_list += '\n'

    return new_list[:-1]


url = _REPO + "search?q=" + sys.argv[1]
print(search_repo(url))
