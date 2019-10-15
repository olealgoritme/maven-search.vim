#!/usr/bin/python
import sys
from urllib import urlopen
from bs4 import BeautifulSoup

# current https://mvnrepository.com/search?q=queryString
# <h2 class="im-title"><span style="font-weight: normal; font-size:90%; color:gray">1. </span><a href="/artifact/org.flywaydb/flyway-core">Flyway Core</a><a class="im-usage" href="/artifact/org.flywaydb/flyway-core/usages"><b>414</b> usages</a></h2>

def get_url(url):
    page = urlopen(url)
    soup = BeautifulSoup(page, 'html.parser')
    res_list = soup.find_all('h2', class_="im-title")

    new_list = '';
    for item in res_list:
        fixed_item = str(item.span.text + " " + item.a.text + " (" + item.a['href'].replace("/artifact/", "").replace("/", ".") + ")").encode('utf-8')
        new_list += fixed_item + str('\n').encode('utf-8')
    return new_list[:-1]

print get_url("https://mvnrepository.com/search?q=" + sys.argv[1])
