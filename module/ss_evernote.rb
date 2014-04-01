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
    attributes.author = AUTHOR
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
end
