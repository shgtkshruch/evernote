require 'nokogiri'
require 'mechanize'

require_relative './subtitle'
require_relative './caption'

class Page
  attr_accessor :title, :url, :captionTitle, :captionBody, :filenames, :subtitle, :pdf

  def initialize
    @html = Nokogiri::HTML(`chrome-cli source`)
    @captionBlock = @html.search('#seq_content .vert-1 .xblock')
    @title = getCourseTitle + ' | ' + getWeekTitle + ' | ' + getLessonTitle
    @url = getURL
  end

  def getURL
    info = `chrome-cli info`
    info[/https?.+/]
  end

  def getLessonTitle
    @html.search('#seq_content h2').first.text
  end

  def getCourseTitle
    @html.search('header nav h2').first.text.delete('|')
  end

  def getWeekTitle
    @html.search('#content #accordion nav .chapter.is-open h3 a').first.text
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

  def pdfURL
    host = 'https://lms.gacco.org' 
    query = '/c4x/gacco/'
    courseNo = @url.lines('/')[5].delete('/')
    lessonNo = getLessonTitle.split('.').first
    host + query + courseNo + '/asset/' + lessonNo + '.pdf'
  end

  def getPDF
    @pdf = Mechanize.new.get(pdfURL).save
  end
end
