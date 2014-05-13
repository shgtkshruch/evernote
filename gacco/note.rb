require 'evernote_oauth'

class Note < Evernote::EDAM::Type::Note
  def initialize(page)
    @title = page.title
    @content = page.subtitle
    @capTitle = page.captionTitle
    @capBody = page.captionBody
    styling
  end

  def styling
    container = '<div style="width:81%;margin-left:auto;margin-right:auto;font-family:Helvetica;font-size:14px;">'

    @content = @content.insert(0, "<h1>#{@title}</h1>")
    @content = @content.insert(0, container)
    # @content = @content.gsub(/。/, "。</p><p>")
    # @content.slice!(-3, 3)
    @content = @content.insert(-1, "<br/><h2>#{@capTitle}</h2>")
    @content = @content.insert(-1, @capBody)
    @content = @content.gsub(/<br>/, '<br/>')
    @content = @content.insert(-1, '</div>')
  end

  def create(
    title: '',
    content: '',
    notebookGuid: '',
    tagNames: [],
    filename: '',
    author: 'shgtkshruch'
  )
    # Create note instance
    note = Evernote::EDAM::Type::Note.new
    note.title = title
    note.content = content
    note.notebookGuid = notebookGuid
    note.tagNames = tagNames

    # Set Note attributes
    attributes = Evernote::EDAM::Type::NoteAttributes.new
    attributes.author = author
    # attributes.sourceURL = sourceURL
    note.attributes = attributes

    n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    n_body += "<en-note>#{note.content}"

    # unless content.empty?
    #   n_body += "<br /><br />"
    # end

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
      # n_body += '<en-media type="' + mimeType[0] + '" hash="' + hexhash + '" /><br />'
    end

    n_body += "</en-note>"
    note.content = n_body

    note
  end
end
