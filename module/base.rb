module Base
  def setupNoteStore
    case EVENV
    when "test"
      client = EvernoteOAuth::Client.new(
        token: DEVELOPER_TOKEN, 
        sandbox: true, 
        service_host: "sandbox.evernote.com"
      )
    when "production"
      client = EvernoteOAuth::Client.new(
        token: DEVELOPER_TOKEN, 
        sandbox: false, 
        service_host: "www.evernote.com"
      )
    end
    @noteStore = client.note_store
  end

  def getNotebook(notebookName)
    notebookList = @noteStore.listNotebooks
    notebook = notebookList.select {|x| x.name == notebookName}.first
    notebook
  end

  def createNote(title, content, notebookGuid, sourceURL, filename)
    # Create note instance
    note = Evernote::EDAM::Type::Note.new()
    note.title = title
    note.content = content
    note.notebookGuid = notebookGuid

    # Set Note attributes
    attributes = Evernote::EDAM::Type::NoteAttributes.new()
    attributes.author = AUTHOR
    attributes.sourceURL = sourceURL
    note.attributes = attributes

    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{note.content}<br />"

    # Set note resource
    mimeType = MIME::Types.type_for(filename)
    hashFunc = Digest::MD5.new()
    file = open(@filename){|io| io.read}
    hexhash = hashFunc.hexdigest(file)

    data = Evernote::EDAM::Type::Data.new()
    data.size = file.size
    data.bodyHash = hexhash
    data.body = file

    resource = Evernote::EDAM::Type::Resource.new()
    resource.mime = "#{mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new()
    resource.attributes.fileName = filename
    note.resources = [resource]

    # Add Resource objects to note body
    n_body += '<br /><en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
    n_body += "</en-note>"
    note.content = n_body

    begin
      @noteStore.updateNote(note)

    rescue Evernote::EDAM::Error::EDAMUserException => edus
      puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
    rescue Evernote::EDAM::Error::EDAMSystemException => edsy
      puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
    rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
      puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
    end
  end
end
