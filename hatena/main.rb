require_relative './config.rb'
require_relative './hatena.rb'
require_relative './model/model.rb'
require_relative '../module/Slidenote.rb'

url = 'http://b.hatena.ne.jp/sh19e/atomfeed'

# Parse xml until last page
while url
  nodes = []
  puts url
  hatena = Hatena.new(url)
  nodes.unshift(hatena.getXML('slide')).flatten!
  model = Mymodel.new
  model.insertData(nodes)
  if model.isUpdate?
    puts "Database is updated"
    break
  end
  url = hatena.next?
end

# Upload to evernote
favorite = Favorite.find(77)
tags = []
favorite.tags.each do |tag|
  tags.push(tag.name)
end
Slidenote.new(favorite.url, tags)

