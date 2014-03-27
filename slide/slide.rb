require 'mechanize'

url = 'http://www.slideshare.net/schoowebcampus/schoo-140327'

agent = Mechanize.new
page = agent.get(url)
p page.title
