require_relative './config'
require_relative '../module/evernote_helper'
require_relative './schoo'

puts 'Class Number'
args = gets.chomp
class_num = args[/^\d+/]

slide = Schoo.new(class_num)
slide.download

# Evernote client
evernote = SsEvernote.new

# Create new note
note = Evernote::EDAM::Type::Note.new
newNote = note.create(
  title: slide.title,
  notebookGuid: evernote.getNotebook(OUTPUTNOTEBOOK).guid,
  sourceURL: slide.url,
  filename: slide.pdf_file,
  tagNames: ['slide']
)

# Create note in Evernote
evernote.ssCreateNote(newNote)

# Remove PDF file
slide.remove


