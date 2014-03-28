require './config.rb'
require './slide.rb'
require './evernote.rb'

# Download slide
slide = Slide.new

# Set up noteStore
slideNote= Slidenote.new

# Get schoo note object
schoo = slideNote.getNotebook(SEARCHNOTE)

# Set note atributes
title = slide.title
content = ''
noteGuid = ''
notebookGuid = schoo.guid
sourceURL = slide.url
filename = slide.filename

# Create note object
note = slideNote.createNoteObject(title, content, noteGuid, notebookGuid, sourceURL, filename)

# Create note in Evernote
slideNote.createNote(note)
