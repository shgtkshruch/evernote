require "evernote_oauth"
require "uri"
require "mechanize"
require "mime/types"
require "base64"

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require "config.rb"

# DEVELOPER_TOKEN = "XXX"
# SEARCHWORD = "XXX"
# NOTEBOOKNAME = {"searchNote" => "XXX", "outputNote" => "XXX"}
# FILENAMEPREFIX = "XXX"
# FILENAME = "XXX"

# Set up the NoteStore client 
case EVENV
when "test"
  client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN, sandbox: true, service_host: "sandbox.evernote.com")
when "production"
  client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN, sandbox: false, service_host: "www.evernote.com")
end

noteStore = client.note_store

# Get some notes include search words
def getNotesGuid(noteStore, notebookGuidHash, words)
  noteGuids = []
  count = 10

  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = words
  filter.notebookGuid = notebookGuidHash["searchNote"]

  spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

  metadataList = noteStore.findNotesMetadata(filter, 0, count, spec)
  metadatas = metadataList.notes
  metadatas.each do |noteMeta|
    noteGuids = noteGuids.push(noteMeta.guid)
  end

  noteGuids
end

# Get notebook guid include search word
def getNotebookGuid(noteStore, notebookName)
  notebookGuid = {}

  notebookList = noteStore.listNotebooks
  notebookList.each do |notebook|
    case notebook.name
    when notebookName["searchNote"]
      notebookGuid["searchNote"] = notebook.guid
    when notebookName["outputNote"]
      notebookGuid["outputNote"] = notebook.guid
    end
  end

  notebookGuid
end

# Get note by guid of note
def getURL(noteStore, noteGuid)
  withContent = true
  withResourcesData = false
  withResourcesRecognition = false
  withResourcesAlternateData = false

  uriRegexp = URI.regexp(['http', 'https'])
  uriList = []
  uriFiltered = ""

  begin
    note = noteStore.getNote(noteGuid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData)

    # Get uriList
    note.content.scan(uriRegexp) do
      uriList.push(URI.parse($&))
    end

    # Filtering uriList
    uriList.each do |uri|
      unless uri.host.include?("feedly") || uri.host.include?("evernote") || uri.path =~ /20[0-9][0-9]/
        uriFiltered = uri.to_s
      end
    end

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end

  uriFiltered
end

def updateNote(noteStore, updateNote)
  n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  n_body += "<en-note>#{updateNote.content}<br />"

  unless updateNote.resources.empty?
    hashFunc = Digest::MD5.new
    image = open(updateNote.resources){|io| io.read}
    mimeType = MIME::Types.type_for(updateNote.resources)
    hexhash = hashFunc.hexdigest(image)

    data = Evernote::EDAM::Type::Data.new()
    data.size = image.size
    data.bodyHash = hexhash
    data.body = image

    resource = Evernote::EDAM::Type::Resource.new()
    resource.mime = "#{mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new()
    resource.attributes.fileName = updateNote.resources

    ### Add Resource objects to note body
    updateNote.resources = [resource]
    n_body += '<br /><en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
  end

  n_body += "</en-note>"

  updateNote.content = n_body

  begin
    note = noteStore.updateNote(updateNote)

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end

  note
end

# Get notebook guids that are search and output
notebookGuidHash = getNotebookGuid(noteStore, NOTEBOOKNAME)

# Get note guid that include keyword
noteGuids = getNotesGuid(noteStore, notebookGuidHash, SEARCHWORD)
puts "Get #{noteGuids.length} note"

# Get note title and content by guid
noteGuids.each do |noteGuid|
  # Get url from note
  url = getURL(noteStore, noteGuid)

  # Get screenshot
  puts "Get screenshot form #{url}"
  `webkit2png --width=960 --fullsize --dir=$HOME/evernote --filename=#{FILENAMEPREFIX} --delay=3 #{url}`

  # Get page title
  page = Mechanize.new

  # Create note instance
  updateNote = Evernote::EDAM::Type::Note.new()
  updateNote.guid = noteGuid
  updateNote.title = page.get("#{url}").title
  updateNote.content = "#{url}"
  updateNote.notebookGuid = notebookGuidHash["outputNote"]
  updateNote.resources = FILENAME

  # Set Note attributes
  attributes = Evernote::EDAM::Type::NoteAttributes.new()
  attributes.author = AUTHOR
  attributes.sourceURL = "#{url}"
  updateNote.attributes = attributes

  # Update note
  puts "Update note..."
  puts "Title: #{updateNote.title}"
  updateNote(noteStore, updateNote)

  `rm #{FILENAME}`
  puts "Update note success!"
end
