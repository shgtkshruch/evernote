require './hatena.rb'
require '.model/model.rb'

url = 'http://b.hatena.ne.jp/sh19e/atomfeed'

# Parse xml until last page
while url
  nodes = []
  puts url
  hatena = Hatena.new(url)
  nodes.unshift(hatena.getXML('slide')).flatten!
  Mymodel.new.insertData(nodes)
  url = hatena.next?
end
