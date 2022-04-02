# coding=utf-8
import random
import requests
from urllib.parse import urlencode
import json

# UA_list
product = ['Mozilla/5.0']
system = ['(Windows NT 10.0; Win64; x64)', '(X11; U; CrOS i686 9.10.0; en-US)', '(Macintosh; Intel Mac OS X 10_12_6)', '(X11; FreeBSD amd64)', '(X11; Linux x86_64)', '(X11; U; FreeBSD i386; zh-tw; rv:31.0)', '(Windows NT 10.0; WOW64; rv:56.0)', '(X11; Linux i586; rv:31.0)', '(Macintosh; Intel Mac OS X 10.12; rv:56.0)', '(X11; FreeBSD amd64; rv:40.0)', '(Windows; U; Windows NT 6.1; en-US)']
platform = ['AppleWebKit/537.36 (KHTML, like Gecko)', 'AppleWebKit/532.5 (KHTML, like Gecko)', 'Gecko/20100101', 'OS/2', 'AppleWebKit/533.20.25 (KHTML, like Gecko)']
extension = ['Chrome/91.0.4472.101 Safari/537.36 Edg/91.0.864.48', 'Gecko/20100101 Firefox/29.0', 'Chrome/60.0.3112.78 Safari/537.36 OPR/47.0.2631.55', 'Chrome/62.0.3202.75 Safari/537.36', 'Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54', 'Chrome/40.0.2214.115 Safari/537.36', 'Chrome/61.0.3163.49 Safari/537.36 OPR/48.0.2685.7', 'Opera/13.0', 'Firefox/56.0', 'Firefox/31.0', '/2; U; Warp 4.5; en-US; rv:1.7.12) Gecko/20050922 Firefox/1.0.7', 'Firefox/40.0', 'Version/5.0.4 Safari/533.20.27']



# UA_String
UA_all = [
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 Edg/91.0.864.48", 
"Mozilla/5.0 (X11; U; CrOS i686 9.10.0; en-US) AppleWebKit/532.5 (KHTML, like Gecko) Gecko/20100101 Firefox/29.0", 
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.78 Safari/537.36 OPR/47.0.2631.55", 
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36", 
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54", 
"Mozilla/5.0 (X11; FreeBSD amd64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36", 
"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.49 Safari/537.36 OPR/48.0.2685.7", 
"Mozilla/5.0 (X11; U; FreeBSD i386; zh-tw; rv:31.0) Gecko/20100101 Opera/13.0", 
"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:56.0) Gecko/20100101 Firefox/56.0", 
"Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0", 
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:56.0) Gecko/20100101 Firefox/56.0", 
"Mozilla/5.0 (OS/2; U; Warp 4.5; en-US; rv:1.7.12) Gecko/20050922 Firefox/1.0.7", 
"Mozilla/5.0 (X11; FreeBSD amd64; rv:40.0) Gecko/20100101 Firefox/40.0", 
"Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27", 
]

# function
def list2():
    tolist = [product, system, platform, extension]
    return tolist

def random_one():
    tolist = list2()
    UAstr = ''
    for ilist in tolist:
        rand = random.random()
        if rand >= 0.08:
            UAstr += ilist[random.randint(0, len(ilist)-1)]+' '
    return UAstr.strip()

def fake_headers(num = 20):
    relist = []
    for i in range(0,20):

        relist.append(dict([('User-agent',random_one())]))
    return relist.copy()

