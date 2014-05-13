require 'mechanize'

class Subtitle
  def initialize(url)
    @url = url
  end

  def getContent
    content = ''
    agent = Mechanize.new
    page = agent.get(@url)
    page.search('text').each{|t| content << '<p>' + t.text + '</p>'}
    return content
  end
end

