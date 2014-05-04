class ImageFile
  attr_accessor :name

  def initialize
    @name = Dir["*-full.png"].first
  end

  def delete
    File.delete(@name)
  end
end
