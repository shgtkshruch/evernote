require 'evernote_oauth'
require 'mime/types'
require 'base64'

class Resource
  attr_accessor :media, :resource

  def initialize(filename)
    @filename = filename
    @media = ''
    @resource = ''
    enMedia
  end

  def enMedia
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

