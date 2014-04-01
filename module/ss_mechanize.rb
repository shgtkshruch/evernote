require 'mechanize'

module SsMechanize
  def mechanize(url)
    agent = Mechanize.new
    @page = agent.get(url)
  end

  def remove
    FileUtils.rm @filename
  end
end
