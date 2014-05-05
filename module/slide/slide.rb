require 'mechanize'

class Slide
  def initialize (url)
    agent = Mechanize.new
    @page = agent.get(url)
  end

  def remove
    Dir['*.pdf'].each {|pdf| File.delete(pdf)}
  end
end
