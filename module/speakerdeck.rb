require_relative './ss_mechanize'

class Speakerdeck
  include SsMechanize
  attr_accessor :title, :filename

  def initialize(url)
    mechanize(url)
    @title = @page.title.gsub(/\s\/\/.+/, '')
    @filename = "#{@title}.pdf"
  end

  def download
    downloadPDF = @page.links_with(:id => 'share_pdf').first
    file = downloadPDF.click
    file.save @filename
  end
end
