require 'mechanize'

class Page
  attr_accessor :url, :title

  def initialize(url)
    @url = url
    getPageTitle
  end

  def getPageTitle
    agent = Mechanize.new
    @title = agent.get(@url).title
  end

  def takeScreenshot
    puts "Take a screenshot form #{@url}"
    `webkit2png --width=1920 --fullsize --dir=$HOME/evernote/screenshot --delay=5 "#{@url}" --js='scrollTo(0, 10000);scrollTo(0, 0);'`
  end
end
