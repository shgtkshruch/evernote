require_relative './config'
require_relative '../module/evernote_helper'

require_relative './page'
require_relative './note'

page = Page.new
page.getPDF
page.getCaption
page.getSubtitle

evernote = SsEvernote.new

# Create subtitle note
note = Note.new(page)
newNote = note.create(
  title: note.title,
  content: note.content,
  notebookGuid: evernote.getNotebook('1304 gacco').guid,
  filenames: page.filenames,
  sourceURL: page.url
)

evernote.ssCreateNote(newNote)
page.filenames.each {|f| File.delete(f)}

# Create PDF note
note = Note.new(page)
newNote = note.create(
  title: note.title + ' 資料',
  notebookGuid: evernote.getNotebook('1304 gacco').guid,
  filenames: [page.pdf],
  sourceURL: page.url
)
evernote.ssCreateNote(newNote)
File.delete(page.pdf)
