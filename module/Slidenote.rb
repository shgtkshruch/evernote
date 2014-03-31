require_relative '../config/token.rb'
require_relative './SsEvernote.rb'
require_relative './SsSlide.rb'

class Slidenote
  include SsEvernote
  include SsSlide

  def initialize(url, tag)
    noteStore = setupNoteStore
    getSlide(url)

    # Set note atributes
    title = @title
    content = ''
    noteGuid = ''
    notebookGuid = getNotebook(SEARCHNOTE).guid
    sourceURL = url
    filename = @filename
    tagNames = tag

    # Create note object
    note = createNoteObject(title, content, noteGuid, notebookGuid, sourceURL, filename, tagNames)

    # Create note in Evernote
    noteStore.createNote(note)

    # Remove PDF file
    remove
  end
end

