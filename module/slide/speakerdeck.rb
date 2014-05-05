require_relative './slide'

class Speakerdeck < Slide
  attr_accessor :title, :filename

  def initialize(url)
    super(url)
    @title = @page.title.gsub(/\s\/\/.+/, '')
    @filename = "#{@title}.pdf"
  end

  def download
    downloadPDF = @page.links_with(:id => 'share_pdf').first
    puts 'Download PDF...'
    file = downloadPDF.click
    file.save @filename
  end
end
