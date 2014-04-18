require_relative './ss_mechanize'

class Slideshare
  include SsMechanize
  attr_accessor :title, :filename

  def initialize(url)
    mechanize(url)
    @title = @page.title
    @filename = "#{@title}.pdf"
  end

  def download
    dirname = 'slide'
    Dir.mkdir dirname
    getSlideshare(dirname)
    convert(dirname)
  end

  def getSlideshare(dirname)
    i = 1
    @page.search('.slide_image').each do |image|
      case i
      when 0...10
        index = "00#{i}"
      when 10...100
        index = "0#{i}"
      else
        index = i
      end
      imageURL = image['data-full'].split(/\?.+/)[0]
      `wget #{imageURL} -O "#{dirname}/#{index}.jpg"`
      i += 1
    end
  end

  def convert(dirname)
    `convert #{dirname}/*.jpg -compress jpeg "#{@filename}"`
    FileUtils.rm Dir.glob '**/*.jpg'
    Dir.rmdir dirname
  end
end
