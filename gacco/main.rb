require 'mechanize'
require_relative './config'
require_relative '../module/ss_evernote'
require_relative '../module/mynote'

include SsEvernote

def getContent
  content = ''
  container = '<div style="width:81%;margin-left:auto;margin-right:auto;font-family:Helvetica;font-size:14px;"><p>'

  agent = Mechanize.new
  page = agent.get(@url)
  page.search('text').each{|t| content << t.text}

  content = content.insert(0, "<h1>#{@title}</h1>")
  content = content.insert(0, container)
  content = content.gsub(/。/, "。</p><p>")
  content.slice!(-3, 3)
  content = content.insert(-1, "<br/><h2>#{@capTitle}</h2>")
  content = content.insert(-1, @capBody)
  content = content.insert(-1, '</div>')
end

def createNote
  noteStore = setupNoteStore
  setupNote
  notebook = getNotebook('1304 gacco')
  setTitle(@title)
  setContent(getContent)
  setResource(@resources)
  setNotebookGuid(notebook.guid)
  begin
    noteStore.createNote(@note)
  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy.errorCode} #{edsy.message}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno.identifier} #{edno.key}"
  end
end

def perse
  html = Nokogiri::HTML(`chrome-cli source`)
  @title = html.search('#seq_content h2').first.text
  @url = html.search('#seq_content .wrapper-downloads .video-tracks a').first.attr('href')
  cap = html.search('#seq_content .vert-1 .xblock')
  @capTitle = cap.search('h2').text
  caption = cap.search('p')
  @capBody = caption.to_s.gsub(/<br>/, '<br/>')
  imgs = caption.search('img')
  @resources = []
  unless imgs.empty?
    imgs.each do |img|
      host = 'lms.gacco.org'
      img = img.attr('src')
      url = host + img
      `wget #{url}`
      @filename = img.to_s.gsub(/.+asset\//, '')
      resource = Resource.new(@filename)
      @capBody.gsub!(/\<img.+?>/, resource.media)
      @resources.push(resource.resource)
    end
  end
end

class Resource
  attr_accessor :media, :resource

  def initialize(filename)
    @filename = filename
    @media = ''
    @resource = ''
    enMedia
  end

  def enMedia
    require 'mime/types'
    require 'base64'

    @mimeType = MIME::Types.type_for(@filename)
    hashFunc = Digest::MD5.new
    @file = open(@filename){|io| io.read}
    @hexhash = hashFunc.hexdigest(@file)
    @media = '<en-media type="' + @mimeType[0] + '" hash="' + @hexhash + '"/>'
  end

  def resource
    data = Evernote::EDAM::Type::Data.new
    data.size = @file.size
    data.bodyHash = @hexhash
    data.body = @file

    resource = Evernote::EDAM::Type::Resource.new
    resource.mime = "#{@mimeType[0]}"
    resource.data = data
    resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
    resource.attributes.fileName = @filename
    @resource = resource
  end
end

perse
getContent
createNote
