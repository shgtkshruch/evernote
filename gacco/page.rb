require 'nokogiri'

require_relative './subtitle'
require_relative './caption'

class Page
  attr_accessor :title, :captionTitle, :captionBody, :filenames, :subtitle

  def initialize
    @html = Nokogiri::HTML(`chrome-cli source`)
    @captionBlock = @html.search('#seq_content .vert-1 .xblock')
    @title = @html.search('#seq_content h2').first.text
  end

  def getSubtitle
    captionURL = @html.search('#seq_content .wrapper-downloads .video-tracks a').first.attr('href')
    subtitlePage = Subtitle.new(captionURL)
    @subtitle = subtitlePage.getContent
  end

  def getCaption
    captionBlock = Caption.new(@captionBlock)
    @captionTitle, @captionBody, @filenames = captionBlock.getCaption
  end
end
