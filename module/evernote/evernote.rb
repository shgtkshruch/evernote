require 'evernote_oauth'
require 'mime/types'
require 'base64'
require_relative '../../config/token'

class SsEvernote
  @noteStore = ''

  def initialize
    case EVENV
    when 'test'
      client = EvernoteOAuth::Client.new(
        token: DEVELOPER_TOKEN, 
        sandbox: true, 
        service_host: 'sandbox.evernote.com'
      )
    when 'production'
      client = EvernoteOAuth::Client.new(
        token: DEVELOPER_TOKEN, 
        sandbox: false, 
        service_host: 'www.evernote.com'
      )
    end
    @noteStore = client.note_store
  end

  def getNotebook(notebookName)
    notebookList = @noteStore.listNotebooks
    notebook = notebookList.select {|x| x.name == notebookName}.first
    notebook
  end

  def getNotebookByTagname(tag)
    notebookList = @noteStore.listNotebooks
    notebookHash = {}
    notebookList.each do |notebook|
      if notebook.name.include?(tag)
        notebookHash.push(:notebook => notebook.name, :tag => tag)
      end
    end
    notebookHash.each do |notebook|
      noteList.each do |note|
        if notebook.include?(note)
          notebook = notebook
          break
        end
      end
    end
    notebook
  end

  def findNotesByWords(notebook, words='')
    # notes = []
    count = 100

    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = words
    filter.notebookGuid = notebook.guid

    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    metadataList = @noteStore.findNotesMetadata(filter, 0, count, spec)
    # metadatas = metadataList.notes
    # metadatas.each do |metadata|
    #   notes.push(metadata)
    # end

    metadataList
  end

  def ssGetNote(noteGuid)
    withContent = true
    withResourcesData = false
    withResourcesRecognition = false
    withResourcesAlternateData = false

    begin
      note = @noteStore.getNote(
        noteGuid, 
        withContent, 
        withResourcesData, 
        withResourcesRecognition, 
        withResourcesAlternateData
      )
    rescue Evernote::EDAM::Error::EDAMUserException => edus
      puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
    rescue Evernote::EDAM::Error::EDAMSystemException => edsy
      puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
    rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
      puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
    end
    note
  end

  def setupNote
    @note = Evernote::EDAM::Type::Note.new
    @attributes = Evernote::EDAM::Type::NoteAttributes.new
    @note.attributes = @attributes
  end

  def setSourceURL(url)
    @note.attributes.sourceURL = url
  end

  def setAuthor(author)
    @note.attributes.author = author
  end

  def setTitle(title)
    @note.title = title
  end

  def setContent(content)
    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{content}</en-note>"
    @note.content = n_body
  end

  def setNoteGuid(guid)
    @note.guid = guid
  end

  def setTags(tags)
    @note.tagNames = tags
  end

  def setNotebookGuid(notebookGuid)
    @note.notebookGuid = notebookGuid
  end

  def setResource(resource)
    @note.resources = []
    @note.resources.push(resource)
  end

  def getResource(filename)
    @mimeType = MIME::Types.type_for(filename)
    hashFunc = Digest::MD5.new
    file = open(filename){|io| io.read}
    @hexhash = hashFunc.hexdigest(file)

    data = Evernote::EDAM::Type::Data.new
    data.size = file.size
    data.bodyHash = @hexhash
    data.body = file

    resource = Evernote::EDAM::Type::Resource.new
    resource.mime = "#{@mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
    resource.attributes.fileName = filename
  end

  def getEnmedia
    '<en-media type="' + @mimeType[0] + '" hash="' + @hexhash + '"/>'
  end

  def ssUpdateNote(note)
    puts "Update note..."
  begin
    @noteStore.updateNote(note)
  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end
    puts "Update #{note.title} note successfully!"
  end

  def ssCreateNote(note)
    puts "Create new note..."
  begin
    @noteStore.createNote(note)
  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end
    puts "Create #{note.title} note successfully!"
  end
end
