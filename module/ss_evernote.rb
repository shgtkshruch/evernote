require 'evernote_oauth'
require 'mime/types'
require 'base64'
require_relative '../config/token'

module SsEvernote
  def setupNoteStore
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
    @noteStore
  end

  def getNotebook(notebookName)
    notebookList = @noteStore.listNotebooks
    notebook = notebookList.select {|x| x.name == notebookName}.first
    notebook
  end

  def getNotebookByTagname(tag)
    notebookList = @noteStore.listNotebooks
    notebookList.each do |notebook|
      if notebook.name.include?(tag)
        notebookHash.push(:notebook => notebook.name, :tag => tag)
      end
    end
    notebookList.each do |notebook|
      noteList.each do |note|
        if notebook.include?(note)
          notebook = notebook
          break
        end
      end
    end
    notebook
  end

  def getNotes(notebook, words='')
    notes = []
    count = 100

    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = words
    filter.notebookGuid = notebook.guid

    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    metadataList = @noteStore.findNotesMetadata(filter, 0, count, spec)
    metadatas = metadataList.notes
    metadatas.each do |metadata|
      notes.push(metadata)
    end

    notes
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

  def createNoteObject(mynote)
    # Create note instance
    note = Evernote::EDAM::Type::Note.new
    note.guid = mynote.noteGuid
    note.title = mynote.title
    note.content = mynote.content
    note.notebookGuid = mynote.notebookGuid
    note.tagNames = mynote.tagNames

    # Set Note attributes
    attributes = Evernote::EDAM::Type::NoteAttributes.new
    attributes.author = AUTHOR if AUTHOR
    attributes.sourceURL = mynote.sourceURL
    note.attributes = attributes

    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{note.content}"

    unless mynote.content.empty?
      n_body += "<br /><br />"
    end

    # Set note resource
    unless mynote.filename.empty?
      mimeType = MIME::Types.type_for(mynote.filename)
      hashFunc = Digest::MD5.new
      file = open(mynote.filename){|io| io.read}
      hexhash = hashFunc.hexdigest(file)

      data = Evernote::EDAM::Type::Data.new
      data.size = file.size
      data.bodyHash = hexhash
      data.body = file

      resource = Evernote::EDAM::Type::Resource.new
      resource.mime = "#{mimeType[0]}"
      resource.data = data
      resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
      resource.attributes.fileName = mynote.filename
      note.resources = [resource]

      # Add Resource objects to note body
      n_body += '<en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
    end

    n_body += "</en-note>"
    note.content = n_body

    note
  end

  def ssUpdateNote(note)
    @noteStore.updateNote(note)
  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end
end
