require_relative './config'
require_relative '../module/evernote_helper'
require_relative '../module/slide_helper'

# Get slide url
puts 'Slide URL'
url = gets.chomp
tags = ['slide']

if url =~ /speakerdeck/
  slide = Speakerdeck.new(url)
elsif url =~ /slideshare/
  slide = Slideshare.new(url)
end

slide.download

# Evernote client
evernote = SsEvernote.new

# Create new note
note = Evernote::EDAM::Type::Note.new
newNote = note.create(
  title: slide.title,
  notebookGuid: evernote.getNotebook(OUTPUTNOTEBOOK).guid,
  sourceURL: url,
  filename: slide.filename,
  tagNames: tags
)

# Create note in Evernote
evernote.ssCreateNote(newNote)

# Remove PDF file
slide.remove
