require_relative './config'
require_relative '../module/evernote_helper'
require_relative './page'
require_relative './file'

evernote = SsEvernote.new
inputNotebook = evernote.getNotebook(INPUTNOTEBOOK)
outputNotebook = evernote.getNotebook(OUTPUTNOTEBOOK)
notesMetadata = evernote.findNotesByWords(inputNotebook, SEARCHWORD)

notesMetadata.hasNote?

notesMetadata.notes.each do |meta|
  note = evernote.ssGetNote(meta.guid)
  url = note.extractURL

  page = Page.new(url)
  page.takeScreenshot

  file = ImageFile.new

  newNote = note.create(
    guid: note.guid,
    title: page.title,
    content: url,
    notebookGuid: outputNotebook.guid,
    tagNames: [],
    sourceURL: url,
    filename: file.name
  )
  evernote.ssUpdateNote(newNote)

  file.delete
end

puts "Update all note successfully!"
