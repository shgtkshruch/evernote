require 'nokogiri'
require 'open-uri'

class Hatena
  def initialize(url)
    @doc =  Nokogiri::XML(open(url))
  end

  def getXML(tagName = '')
    node = {}
    nodes = []
    @doc.search('entry author').each do |author|
      item = author
      if item.next_element()
        entry = item.parent
        title = entry.search('title').text()
        links = entry.search('link')
        href = ''
        tagNodes = []
        while item.next_element()
          tagNodes.push(item.next_element())
          item = item.next_element()
        end
        tags = []
        tagNodes.each do |tagNode|
          tag = tagNode.children.to_s 
          tags.push(tag)
          unless tagName.nil?
            if tag.include? "#{tagName}"
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
                node = {:title => title, :link => href, :tags => tags}
                nodes.unshift(node) 
              end
            end
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
