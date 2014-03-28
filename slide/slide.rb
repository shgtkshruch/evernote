require 'mechanize'

class Slide
  attr_accessor :title, :url, :filename

  def initialize
    puts 'Slideshare URL'
    @url = gets.chomp
    agent = Mechanize.new
    page = agent.get @url
    dirname = 'slide'
    @title = page.title
    @filename = "#{@title}.pdf"
    Dir.mkdir dirname
    getSlide(page, dirname)
    convert(dirname, @filename)
  end

  def getSlide(page, dirname)
    i = 1
    page.search('.slide_image').each do |image|
      index = i < 10 ? "0#{i}" : i
      imageURL = image['data-full'].split(/\?.+/)[0]
      `wget #{imageURL} -O "#{dirname}/#{index}.jpg"`
      i += 1
    end
  end

  def convert(dirname, filename)
    `convert #{dirname}/*.jpg -compress jpeg "#{filename}"`
    FileUtils.rm Dir.glob '**/*.jpg'
    Dir.rmdir dirname
  end

  def remove(filename)
    FileUtils.rm filename
  end
end
