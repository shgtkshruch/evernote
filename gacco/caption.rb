require_relative './resource'

class Caption
  def initialize(page)
    @captionBlock = page
  end

  def getCaption
    captionTitle = @captionBlock.search('h2').text
    @captionBody = @captionBlock.search('p')
    getCaptionImage
    return captionTitle, @captionBody.to_s, @filenames
  end

  def getCaptionImage
    @filenames = []
    imgs = @captionBody.search('img')
    imgs.each do |img|
      unless img.to_s.empty?
        host = 'lms.gacco.org'
        img = img.attr('src')
        url = host + img
        `wget #{url}`
        convertEnmedia(img)
      end
    end
  end

  def convertEnmedia(img)
    filename = img.to_s.gsub(/.+asset\//, '')
    @filenames.push(filename)
    resource = Resource.new(filename)
    @captionBody = @captionBody.to_s.gsub(/<img.+#{filename}">/, resource.media)
  end
end
