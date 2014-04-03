require_relative './config'
require_relative './hatena'
require_relative './model/model'
require_relative '../module/slide_note'

url = 'http://b.hatena.ne.jp/sh19e/atomfeed'

# Parse xml until last page
if url
  nodes = []
  puts url
  hatena = Hatena.new(url)
  nodes.unshift(hatena.getXML).flatten!
  model = Mymodel.new
  model.insertData(nodes)
  if model.isUpdate?
    puts "Database is updated"
    # break
  end
  url = hatena.next?
end

# Upload to evernote
# favorite = Favorite.find(77)
# tags = []
# favorite.tags.each do |tag|
#   tags.push(tag.name)
# end
# slideNote(favorite.url, tags)
#
