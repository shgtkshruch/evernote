require 'json'
require_relative './config'
require_relative '../module/evernote_helper'

def get_json
  `wget http://dreamafar.qiniudn.com/destination.json`
end

def delete_json
  File.delete('destination.json')
end

def get_destinations
  get_json
  destinations = []
  open('destination.json') do |io|
    f = JSON.load(io)
    f['destinations'].each do |d|
      destinations.push({alias: d['alias'], name: d['name'], photoCount: d['photoCount']})
    end
  end
  destinations
end

def upload(evernote, filename, title, url)
  note = Evernote::EDAM::Type::Note.new

  # create note object
  newNote = note.create(
    title: title,
    notebookGuid: evernote.getNotebook(OUTPUTNOTEBOOK).guid, 
    sourceURL: url,
    filename: filename
  )

  # upload to evernote
  evernote.ssCreateNote(newNote)

  # delete image file
  File.delete(filename)
end

def is_download?(destination)
  # destinations array
  destinations = File.open('cache.txt').read.scan(/\w+/)
  destinations.include?(destination)
end

def cache(title)
  File.open('cache.txt', 'a'){ |f| f.puts(title) }
end

def get_image_info(destination, i)
  filename = destination + '_' + i.to_s + '.jpg'
  url = 'http://dreamafar.qiniudn.com/' + filename
  return filename, url
end


###
# main
###

# set up evernote
evernote = SsEvernote.new

get_destinations.each do |d|
  destination = d[:alias]
  name = d[:name]
  count = d[:photoCount]

  # If you have ever doanloaded skipped.
  # If not, destination name add to cache.
  if is_download?(destination)
    next
  else
    cache(destination)
  end

  (1..count).each do |i|
    filename, url = get_image_info(destination, i)

    # download image
    `wget #{url}`

    # upload to evernote
    upload(evernote, filename, name, url)
  end
end

# delete destination.json file
delete_json
