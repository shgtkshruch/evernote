require_relative './ss_evernote'
require_relative './slideshare'
require_relative './speakerdeck'
require_relative './mynote'

include SsEvernote

def slideNote(url, tags=[])
  if url =~ /speakerdeck/
    slide = Speakerdeck.new(url)
  elsif url =~ /slideshare/
    slide = Slideshare.new(url)
  end
  slide.download

  # Evernote client
  noteStore = setupNoteStore

  # Set note atributes
  mynote = Mynote.new
  mynote.title = slide.title
  mynote.content = ''
  mynote.noteGuid = ''
  mynote.notebookGuid = getNotebook(SEARCHNOTE).guid
  mynote.sourceURL = url
  mynote.filename = slide.filename
  mynote.tagNames = tags

  # Create note object
  note = createNoteObject(mynote)

  # Create note in Evernote
  noteStore.createNote(note)

  # Remove PDF file
  slide.remove
end
