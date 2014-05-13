require_relative './config'
require_relative '../module/evernote_helper'

require_relative './page'
require_relative './note'

page = Page.new
page.getCaption
page.getSubtitle

evernote = SsEvernote.new
note = Note.new(page)
newNote = note.create(
  title: note.title,
  content: note.content,
  notebookGuid: evernote.getNotebook('1304 gacco').guid,
  filenames: page.filenames
)

evernote.ssCreateNote(newNote)

page.filenames.each {|f| File.delete(f)}
