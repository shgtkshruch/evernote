require 'nokogiri'
require 'open-uri'
require_relative 'get_images'

class Schoo
  include Get_images
  attr_accessor :title, :pdf_file, :url

  def initialize(class_num)
    @class_num = class_num
    @class_url = 'http://schoo.jp/class/' + @class_num
    @dirname = 'images'
    @url = @class_url
  end

  def download
    get_info
    get_images(@class_num)
    convert
  end

  def get_info
    doc = Nokogiri::HTML(open(@class_url))

    @title = doc.search('#globe > div.content.clearfix > div.wrap.clearfix > div.mainCol > div.shadowbox > div.eyeCatch.clearfix > div > div.mainSide > header > div.title.ovh > h1').text
    modified
    @slide_url = "https://s3-ap-northeast-1.amazonaws.com/i.schoo/images/class/slide/#{@class_num}/"
    @pdf_file = @title + '.pdf'
  end

  def modified
    @title = @title.gsub(/\//, '')
  end

  def convert
    `convert *.jpg -compress jpeg "#{@pdf_file}"`
  end

  def remove
    Dir["*.jpg"].each do |image|
      File.delete(image)
    end

    File.delete(@pdf_file)
  end
end
