require "evernote_oauth"
require "uri"
require "mechanize"
require "mime/types"
require "base64"

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require "config.rb"

# Set up the NoteStore client 
client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN)
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
  uri = []

  begin
    note = noteStore.getNote(noteGuid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData)

    # Get url
    note.content.scan(uriRegexp) do
      uriList.push(URI.parse($&))
    end
    uri = uriList.uniq.slice(1)

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end

  uri
end

def updateNote(noteStore, noteGuid, noteTitle, noteBody, notebookGuidHash, filename)
  our_note = Evernote::EDAM::Type::Note.new
  our_note.guid = noteGuid
  our_note.title = noteTitle
  our_note.notebookGuid = notebookGuidHash["outputNote"]

  n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  n_body += "<en-note>#{noteBody}<br />"

  unless filename.empty?
    hashFunc = Digest::MD5.new
    image = open(filename){|io| io.read}
    mimeType = MIME::Types.type_for(filename)
    hexhash = hashFunc.hexdigest(image)

    data = Evernote::EDAM::Type::Data.new()
    data.size = image.size
    data.bodyHash = hexhash
    data.body = image

    resource = Evernote::EDAM::Type::Resource.new()
    resource.mime = "#{mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new()
    resource.attributes.fileName = filename

    ### Add Resource objects to note body
    our_note.resources = [resource]
    n_body += '<br /><en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
  end

  n_body += "</en-note>"

  our_note.content = n_body

  begin
    note = noteStore.updateNote(our_note)

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end

  note
end

# Variables
searchWord = "web_design_evernote"
notebookName = {"searchNote" => "inbox", "outputNote" => "Web design"}
filenamePrefix = "ToEvernote"
filename = "#{filenamePrefix}-full.png"

# Get notebook guids that are search and output
notebookGuidHash = getNotebookGuid(noteStore, notebookName)

# Get note guid that include keyword
noteGuids = getNotesGuid(noteStore, notebookGuidHash, searchWord)
puts "Get #{noteGuids.length} note"

# Get note title and content by guid
noteGuids.each do |noteGuid|
  # Get url from note
  url = getURL(noteStore, noteGuid)

  # Set note body
  noteBody = "#{url}"

  # Get screenshot
  puts "Get screenshot form #{url}"
  `webkit2png --width=960 --fullsize --dir=$HOME/evernote --filename=#{filenamePrefix} --delay=3 #{url}`

  # Get page title
  page = Mechanize.new
  pageTitle = page.get("#{url}").title

  # Update note
  puts "Update note..."
  puts "Title: #{pageTitle}"
  updateNote(noteStore, noteGuid, pageTitle, noteBody, notebookGuidHash, filename)

  `rm #{filename}`
  puts "Update note success!"
end
