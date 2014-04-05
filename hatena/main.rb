require_relative './config'
require_relative './hatena'
require_relative './model/model'
require_relative '../module/slide_note'
require_relative '../pocket/ss_pocket'

# Parse xml until last page
def getItems
  url = 'http://b.hatena.ne.jp/sh19e/atomfeed'
  while url
    nodes = []
    puts url
    hatena = Hatena.new(url)
    nodes.unshift(hatena.getXML).flatten!
    model = Mymodel.new
    model.insertData(nodes)
    if model.isUpdate?
      puts "Database is updated"
      break
    end
    url = hatena.next?
    exit 1
  end
end

def addPocket
  favorite = Favorite.all
  favorite.each do |f|
    if f.pocket == 0
      tags = ''
      f.tags.each do |tag|
        tags << "#{tag.name},"
      end
      pocket = SsPocket.new
      pocket.add(f.url, tags)
      f.pocket = 1 
      f.save
      puts "#{f.title} send to Pocket"
    else
      puts "#{f.title} have been sent to Pocket"
    end
  end
end

def addEvernote
  # Upload to evernote
  favorites = Favorite.all
  favorites.each do |f|
    if f.evernote == 0
      tags = []
      f.tags.each do |tag|
        tags.push(tag.name)
      end
      if tags.include?('slide')
        puts f.title
        puts tags
        # slideNote(favorite.url, tags)
        # f.evernote = 1
        # f.save
      end
    end
  end
end
