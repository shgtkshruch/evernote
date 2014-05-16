require 'nokogiri'

class Period
  def self.go
    readFile
    createWordList
    addTag
  end

  def self.readFile
    file = open('ma.txt')
    @doc = Nokogiri::XML(file)
  end

  def self.createWordList
    @a = []
    @words = @doc.search('word')
    @words.each do |word|
      t = word.search('surface').children.text
      pos = word.search('pos').children.text
      @a.push([t,pos]) 
    end
  end
  
  def self.addTag
    r = '<p>'
    i = 0
    while i < @words.length - 1
      if @a[i][1] == '助動詞' and @a[i+1][1] == '特殊' and (@a[i+1][0] != '。' and @a[i+1][0] != '、' and @a[i+1][0] != '」')
        r << (@a[i][0].chomp + '。' + '</p><p>')
      elsif @a[i][0].include?('。')
        r << (@a[i][0].chomp + '</p><p>')
      elsif @a[i][0] == ' '
        r << ''
      else
        r << @a[i][0].chomp
      end
      i = i + 1
    end
    r.slice!(-3, 3)
    result = ''
    r.each_line('</p>') {|line| result << line}
    result
  end
end
