require 'nokogiri'
require 'open-uri'

class Hatena
  def initialize(url)
    @doc =  Nokogiri::XML(open(url))
  end

  def getXML(tagName = '')
    node = {}
    nodes = []
    @doc.search('entry').each do |entry|
      title = entry.search('title').text
      links = entry.search('link')
      issued = entry.search('issued').text
      author = entry.search('author').first

      tagNodes = []
      while author.next_element()
        tagNodes.push(author.next_element())
        author = author.next_element()
      end

      tags = []
      tagNodes.each do |tagNode|
        tag = tagNode.children.to_s 
        tags.push(tag)
      end

      unless tagName.empty?
        if tags.include? "#{tagName}"
          isTag = true
        else
          isTag = false
        end
      else
        isTag = true
      end

      if isTag
        links.each do |link|
          if link.attribute('rel').value == 'related'
            href = link.attribute('href').to_s
            node = {:title => title, :link => href, :issued => issued, :tags => tags}
            nodes.unshift(node) 
          end
        end
      end
    end
    nodes
  end

  def next?
    linkNext = @doc.search('feed > link[rel=next]').first
    unless linkNext.nil?
      linkNext.attribute('href')
    end
  end
end
