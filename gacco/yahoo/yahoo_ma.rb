require 'nokogiri'
require 'open-uri'
require 'uri'

require_relative './config'
require_relative './period'

class Ma
  def initialize(text)
    @text = text
    @break = '@@@'
  end

  def analyse
    addHeader
    ma(devideSentence)
    addFooter
    result = Period.go
    File.delete('ma.txt')
    result
  end

  def devideSentence
    s = ''
    i = 0
    @text.each_line(' ') do |sentence|
      if i == 30
        s << sentence + @break
        i = 0
      else
        s << sentence.chomp
      end
      i = i + 1
    end
    s.gsub!(/\&quot\;/, '"')
    s
  end

  def ma(s)
    request_url = 'http://jlp.yahooapis.jp/MAService/V1/parse'
    results = 'ma'
    response = 'surface,pos'
    uniq_filter = ''
    s.each_line(@break) do |sentence|
      sentence.delete!(@break)
      encode_sentence = URI.escape(sentence)
      url = request_url + '?appid=' + APPID + '&results=' + results + '&response=' + response + '&uniq_filter=' + uniq_filter + '&sentence=' + encode_sentence
      res = Nokogiri::XML(open(url))
      File.open('ma.txt', 'a'){|f| f.puts(res.search('word'))}
    end
  end

  def addHeader
    header = '<ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:jp:jlp" xsi:schemaLocation="urn:yahoo:jp:jlp http://jlp.yahooapis.jp/MAService/V1/parseResponse.xsd"><ma_result><word_list>'
    File.open('ma.txt', 'a'){|f| f.puts(header)}
  end

  def addFooter
    footer = '</word_list></ma_result></ResultSet>'
    File.open('ma.txt', 'a'){|f| f.puts(footer)}
  end
end
