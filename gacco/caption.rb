require_relative './resource'

class Caption
  def initialize(page)
    @captionBlock = page
  end

  def getCaption
    captionTitle = @captionBlock.search('h2').text
    @captionBody = @captionBlock.search('p')
    getCaptionImage
    return captionTitle, @captionBody.to_s, @filename
  end

  def getCaptionImage
    img = @captionBody.search('img')
    unless img.empty?
      host = 'lms.gacco.org'
      img = img.attr('src')
      url = host + img
      `wget #{url}`
      convertEnmedia(img)
    end
  end

  def convertEnmedia(img)
    @filename = img.to_s.gsub(/.+asset\//, '')
    resource = Resource.new(@filename)
    @captionBody = @captionBody.to_s.gsub(/<img.+?>/, resource.media)
  end
end
