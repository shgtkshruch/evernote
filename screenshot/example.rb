require "evernote_oauth"
require "uri"
require "mechanize"
require "mime/types"
require "base64"

EVENV = "production"
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require "../config/token.rb"
require "./config.rb"
require "../module/base.rb"

# DEVELOPER_TOKEN = "XXX"
# SEARCHWORD = "XXX"
# NOTEBOOKNAME = {"searchNote" => "XXX", "outputNote" => "XXX"}
# AUTHOR = "XXX"

class ScreenshotToEvernote
  include Base

  def initialize
    setupNoteStore
    inputNotebook = getNotebook(INPUTNOTEBOOK)
    outputNotebook = getNotebook(OUTPUTNOTEBOOK)
    @notes = getNotes(inputNotebook, SEARCHWORD)
    hasNote?
    @notes.each do |note|
      @noteGuid = note.guid
      getURL(@noteGuid)
      getScreenshot
      getPageTitle
      getFilename
      updateNote(outputNotebook)
      endOperation
    end
    puts "Update all note successfully!"
  end

  def hasNote?
    case @notes.length
    when 0
      puts "Not found note"
      exit 1
    when 1
      puts "Get #{@notes.length} note"
    else 
      puts "Get #{@notes.length} notes"
    end
  end

  def getNotes(notebook, words)
    notes = []
    count = 10

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

  def getURL(noteGuid)
    withContent = true
    withResourcesData = false
    withResourcesRecognition = false
    withResourcesAlternateData = false

    uriRegexp = URI.regexp(['http', 'https'])
    uriList = []

    begin
      note = @noteStore.getNote(
        noteGuid, 
        withContent, 
        withResourcesData, 
        withResourcesRecognition, 
        withResourcesAlternateData
      )

      # Get uriList
      note.content.scan(uriRegexp) do
        uriList.push(URI.parse($&))
      end

      # Filtering uriList
      uriList.each do |uri|
        unless uri.host.include?("feedly") || uri.host.include?("evernote") || uri.host.include?("fullrss") || uri.path =~ /20[0-9][0-9]/
          @url = uri.to_s
        end
      end

    rescue Evernote::EDAM::Error::EDAMUserException => edus
      puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
    rescue Evernote::EDAM::Error::EDAMSystemException => edsy
      puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
    rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
      puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
    end

    @url
  end

  def getScreenshot
    puts "Get screenshot form #{@url}"
    `webkit2png --width=960 --fullsize --dir=$HOME/evernote/screenshot --delay=3 #{@url}`
  end

  def getPageTitle
    page = Mechanize.new()
    @pageTitle = page.get("#{@url}").title
  end

  def getFilename
    @filename = "#{@url.gsub(/https?:\/\//, "").gsub(/[.\/\-]/, "")}-full.png"
  end

  def updateNote(notebook)
    puts "Update note..."

    # Create note instance
    note = Evernote::EDAM::Type::Note.new
    note.guid = @noteGuid
    note.title = @pageTitle
    note.content = "#{@url}"
    note.notebookGuid = notebook.guid

    # Set Note attributes
    attributes = Evernote::EDAM::Type::NoteAttributes.new
    attributes.author = AUTHOR
    attributes.sourceURL = "#{@url}"
    note.attributes = attributes

    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{note.content}<br />"

    # Set note resource
    mimeType = MIME::Types.type_for(@filename)
    hashFunc = Digest::MD5.new()
    image = open(@filename){|io| io.read}
    hexhash = hashFunc.hexdigest(image)

    data = Evernote::EDAM::Type::Data.new
    data.size = image.size
    data.bodyHash = hexhash
    data.body = image

    resource = Evernote::EDAM::Type::Resource.new
    resource.mime = "#{mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
    resource.attributes.fileName = @filename
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

  def endOperation
    `rm #{@filename}`
    puts "Update #{@pageTitle} note successfully!"
  end
end

ScreenshotToEvernote.new
