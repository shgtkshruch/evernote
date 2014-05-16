require 'mechanize'
require_relative './yahoo/yahoo_ma'

class Subtitle
  def initialize(url)
    @url = url
  end

  def getContent
    content = ''
    agent = Mechanize.new
    page = agent.get(@url)
    page.search('text').each{|t| content << t.text + ' '}
    ma = Ma.new(content)
    result = ma.analyse
    return result
  end
end

