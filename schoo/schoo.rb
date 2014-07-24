require 'nokogiri'
require 'open-uri'

class Schoo
  attr_accessor :title, :pdf_file, :url
  def initialize(class_num, slide_num)
    @class_num = class_num
    @slide_num = slide_num
    @class_url = 'http://schoo.jp/class/' + @class_num
    @dirname = 'images'
  end

  def download
    get_info
    mkdir
    get_images
    convert
  end

  def get_info
    doc = Nokogiri::HTML(open(@class_url))

    @title = doc.title()
    @slide_url = "https://s3-ap-northeast-1.amazonaws.com/i.schoo/images/class/slide/#{@class_num}/"
    @pdf_file = @title + '.pdf'
  end

  def mkdir
    Dir.mkdir(@dirname)
  end

  def get_index(i)
    case i
    when 0...10
      index = "00#{i}"
    when 10...100
      index = "0#{i}"
    else
      index = i
    end
    index
  end

  def get_images
    i = 1
    while @slide_num > 0 do
      index = get_index(i)
      slide_url = @slide_url + i.to_s + '-1024.jpg'
      `wget #{slide_url} -O "#{@dirname}/#{index}.jpg"`
      i = i + 1
      @slide_num = @slide_num - 1
    end
  end

  def convert
    `convert #{@dirname}/*.jpg -compress jpeg "#{@pdf_file}"`
  end

  def remove
    Dir["#{@dirname}/*"].each do |image|
      File.delete(image)
    end

    Dir.delete(@dirname)
    File.delete(@pdf_file)
  end
end
