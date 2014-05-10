require 'mechanize'

class Page
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def getTitle
    agent = Mechanize.new
    agent.get(@url).title
  end

  def takeScreenshot
    puts "Take a screenshot form #{@url}"
    `webkit2png --width=1920 --fullsize --dir=$HOME/evernote/screenshot --delay=5 "#{@url}" --js='scrollTo(0, 10000);scrollTo(0, 0);'`
  end
end
