require 'uri'
require 'mechanize'

require_relative './config'
require_relative '../config/token'
require_relative '../module/ss_evernote'
require_relative '../module/mynote'

# DEVELOPER_TOKEN = "XXX"
# SEARCHWORD = "XXX"
# NOTEBOOKNAME = {"searchNote" => "XXX", "outputNote" => "XXX"}
# AUTHOR = "XXX"

class ScreenshotToEvernote
  include SsEvernote

  def initialize
    @noteStore = setupNoteStore
    inputNotebook = getNotebook(INPUTNOTEBOOK)
    outputNotebook = getNotebook(OUTPUTNOTEBOOK)
    notes = getNotes(inputNotebook, SEARCHWORD)
    hasNote?(notes)
    notes.each do |note|
      url = getURL(note.guid)
      title = getPageTitle(url)
      getScreenshot(url)

      filename = getFilename(url)

      mynote = Mynote.new
      mynote.title = title
      mynote.content = url
      mynote.noteGuid = note.guid
      mynote.notebookGuid = outputNotebook.guid
      mynote.sourceURL = url
      mynote.filename = filename

      note = createNoteObject(mynote)

      puts "Update note..."
      @noteStore.updateNote(note)
      endOperation(filename, title)
    end
    puts "Update all note successfully!"
  end

  def hasNote?(notes)
    case notes.length
    when 0
      puts "Not found note"
      exit 1
    when 1
      puts "Get #{notes.length} note"
    else 
      puts "Get #{notes.length} notes"
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
    url = ''

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
          url = uri.to_s
        end
      end

    rescue Evernote::EDAM::Error::EDAMUserException => edus
      puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
    rescue Evernote::EDAM::Error::EDAMSystemException => edsy
      puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
    rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
      puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
    end

    url
  end

  def getScreenshot(url)
    puts "Get screenshot form #{url}"
    `webkit2png --width=960 --fullsize --dir=$HOME/evernote/screenshot --delay=4 "#{url}"`
  end

  def getPageTitle(url)
    page = Mechanize.new()
    pageTitle = page.get("#{url}").title
    pageTitle
  end

  def getFilename(url)
    filename = "#{url.gsub(/https?:\/\//, "").gsub(/[.\/\-#]/, "")}-full.png"
    filename
  end

  def endOperation(filename, title)
    `rm #{filename}`
    puts "Update #{title} note successfully!"
  end
end

ScreenshotToEvernote.new
