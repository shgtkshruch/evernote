require 'mechanize'

module SsSlide
  attr_accessor :title, :url, :filename

  def getSlide(url)
    agent = Mechanize.new
    @page = agent.get url

    if url =~ /speakerdeck/
      @title = @page.title.gsub(/\s\/\/.+/, '')
      @filename = "#{@title}.pdf"
      speakerdeck
    elsif url =~ /slideshare/ 
      @title = @page.title
      @filename = "#{@title}.pdf"
      slideshare
    end
  end

  def speakerdeck
    downloadPDF = @page.links_with(:id => 'share_pdf').first
    file = downloadPDF.click
    file.save @filename
  end

  def slideshare
    dirname = 'slide'
    Dir.mkdir dirname
    getSlideshare(dirname)
    convert(dirname)
  end

  def getSlideshare(dirname)
    i = 1
    @page.search('.slide_image').each do |image|
      index = i < 10 ? "0#{i}" : i
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

  def remove
    FileUtils.rm @filename
  end
end
