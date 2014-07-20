require 'nokogiri'

class Schoo
  attr_accessor :title, :pdf_file, :url

  def download
    get_info
    mkdir
    get_images
    convert
  end

  def get_info
    doc = Nokogiri::HTML(`chrome-cli source`)
    page = `chrome-cli info`

    @title = doc.search('#globe > div.content.clearfix > div.wrap.clearfix > div.mainCol > div.shadowbox > div.eyeCatch.clearfix > div > div.mainSide > header > div.title.ovh > h1').text()
    @url = page.split(/\n/)[2].gsub('Url: ', '')

    class_num = page.split(/\n/)[2].gsub('Url: http://schoo.jp/class/', '')
    @slide_url = "https://s3-ap-northeast-1.amazonaws.com/i.schoo/images/class/slide/#{class_num}/"
    @slide_num = doc.search('#slideshow > div.slide_control > div.jump > span').text()[/\d.+/].to_i

    @pdf_file = @title + '.pdf'
    @dirname = 'images'
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
