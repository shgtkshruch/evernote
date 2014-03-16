require "evernote_oauth"
require "uri"

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require "config.rb"

# Set up the NoteStore client 
client = EvernoteOAuth::Client.new(token: DEVELOPER_TOKEN)
noteStore = client.note_store

# Variables
noteGuids = []
webTagsGuid = []
url = ""

# Get some notes by search words or guid of tag
def getNotesGuid(noteStore, noteGuids, words, tagGuids)

  count = 5

  filter = Evernote::EDAM::NoteStore::NoteFilter.new
  filter.words = words
  filter.tagGuids = tagGuids

  spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
  spec.includeTitle = true

  metadataList = noteStore.findNotesMetadata(filter, 0, count, spec)
  metadatas = metadataList.notes
  metadatas.each do |noteMeta|
    noteGuids.push(noteMeta.guid)
  end

end

# Get note by guid of note
def getURL(noteStore, noteGuids, url)

  withContent = true
  withResourcesData = false
  withResourcesRecognition = false
  withResourcesAlternateData = false

  begin
    noteGuids.each do |guid|
      note = noteStore.getNote(guid, withContent, withResourcesData, withResourcesRecognition, withResourcesAlternateData)

      # Get url
      uriRegexp = URI.regexp(['http', 'https'])
      uriList = []
      note.content.scan(uriRegexp) do
        uriList.push(URI.parse($&))
      end
      url = uriList.uniq.slice(1)
    end

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end

end

# Get tag guid by search tag name
def getTag(noteStore, tagsGuid, tagName)

  begin
    listTags = noteStore.listTags 
    listTags.each do |tag|
      if tag.name === tagName
        tagsGuid.push(tag.guid)
      end
    end

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno}"
  end

end

# Get tag guid that is named "web"
getTag(noteStore, webTagsGuid, "web")

# Get note guid that has "web" tag
getNotesGuid(noteStore, noteGuids, "web_design_evernote", webTagsGuid)

# Get note title and content by guid
getURL(noteStore, noteGuids, url)

# Get screenshot
`webkit2png -F #{url}`
