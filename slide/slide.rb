require 'mechanize'

class Slide
  attr_accessor :title, :url, :filename

  def initialize
    puts "Slideshare URL"
    url = gets
    agent = Mechanize.new
    @page = agent.get url
    @dirname = 'slide'
    @title = @page.title
    @filename = "#{@title}.pdf"
    Dir.mkdir @dirname
    getSlide
    convert
  end

  def getSlide
    i = 1
    @page.search('.slide_image').each do |image|
      index = i < 10 ? "0#{i}" : i
      imageURL = image['data-full'].split(/\?.+/)[0]
      `wget #{imageURL} -O "#{@dirname}/#{index}.jpg"`
      i += 1
    end
  end

  def convert
    `convert #{@dirname}/*.jpg -compress jpeg "#{@filename}"`
    FileUtils.rm Dir.glob "**/*.jpg"
    Dir.rmdir @dirname
  end
end
