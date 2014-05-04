require 'evernote_oauth'

class Evernote::EDAM::Type::Note
  def extractURL
    uriRegexp = URI.regexp(['http', 'https'])
    uriList = []
    url = ''

    # Get uriList
    self.content.scan(uriRegexp) do
      uriList.push(URI.parse($&))
    end

    # Filtering uriList
    uriList.each do |uri|
      unless uri.host.include?("feedly") \
        || uri.host.include?("evernote") \
        || uri.host.include?("fullrss")
        url = uri.to_s
      end
    end

    url
  end

  def create(
    guid: '',
    title: '',
    content: '',
    notebookGuid: '',
    tagNames: [],
    sourceURL: '',
    filename: '',
    author: 'shgtkshruch'
  )
    # Create note instance
    note = Evernote::EDAM::Type::Note.new
    note.guid = guid
    note.title = title
    note.content = content
    note.notebookGuid = notebookGuid
    note.tagNames = tagNames

    # Set Note attributes
    attributes = Evernote::EDAM::Type::NoteAttributes.new
    attributes.author = author
    attributes.sourceURL = sourceURL
    note.attributes = attributes

    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{note.content}"

    unless content.empty?
      n_body += "<br /><br />"
    end

    # Set note resource
    unless filename.empty?
      mimeType = MIME::Types.type_for(filename)
      hashFunc = Digest::MD5.new
      file = open(filename){|io| io.read}
      hexhash = hashFunc.hexdigest(file)

      data = Evernote::EDAM::Type::Data.new
      data.size = file.size
      data.bodyHash = hexhash
      data.body = file

      resource = Evernote::EDAM::Type::Resource.new
      resource.mime = "#{mimeType[0]}"
      resource.data = data
      resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
      resource.attributes.fileName = filename
      note.resources = [resource]

      # Add Resource objects to note body
      n_body += '<en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
    end

    n_body += "</en-note>"
    note.content = n_body

    note
  end
end
