from BeautifulSoup import BeautifulSoup
import urllib2
import re

match_page = "http://livetv.sx/enx/eventinfo/793875_chelsea_burnley/"
top_page = "http://livetv.sx/enx/allupcomingsports/1/"
# sop://
from StringIO import StringIO
import gzip

myteams = "chelsea barcelona manchester_utd manchester_city liverpool atletico_madrid tottenham arsenal"
all_sopcast = []
def html2text(html_link):
  request = urllib2.Request(html_link)
  request.add_header('Accept-encoding', 'gzip')
  response = urllib2.urlopen(request)
  if response.info().get('Content-Encoding') == 'gzip':
    buf = StringIO(response.read())
    f = gzip.GzipFile(fileobj=buf)
    data = f.read()
  return data

def sopcast(html_link, match_name):
  soup = BeautifulSoup(html2text(html_link))
  sopcast_links=[]
  for link in soup.findAll('a', attrs={'href': re.compile("^sop://") }):
      sopcast_links.append(link.get('href'))
  i = 0
  if len(sopcast_links) < 1:
   return None
  game = match_name
  while i < len(sopcast_links):
     game = game + "," + sopcast_links[i]
     i += 1
  #print (game)
  all_sopcast.append(game)
  return
 
def sopcast_csv ():
  import csv
  with open('/srv/http/sopcast/sopcast_file.csv', mode='w') as sopcast_file:
   i = 0
   while i < len(all_sopcast):
     i += 1
     sopcast_file.write(str(i) + "," + all_sopcast[i-1] + "\n")
  sopcast_file.close
  return

soup = BeautifulSoup(html2text(top_page))
links=[]
for link in soup.findAll('a', attrs={'href': re.compile("/enx/eventinfo/") }):
    links.append(link.get('href'))
 
i = 0
auxiliaryList = []
while i < len(links):
   for team in myteams.split(' '):
     if team in links[i]:
       match_name = links[i].split('/')[3]
       if match_name not in auxiliaryList:
	    match_page = "http://livetv.sx" + links[i]
	    sopcast(match_page, match_name)
	    auxiliaryList.append(match_name)
	    break
   i += 1

sopcast_csv()
