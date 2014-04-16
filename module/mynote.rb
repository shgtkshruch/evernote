class Mynote
  attr_accessor :title, :content, :noteGuid, :notebookGuid, :sourceURL, :filename, :tagNames

  def initialize
    @title = ''
    @content = ''
    @noteGuid = ''
    @notebookGuid = ''
    @sourceURL = ''
    @filename = []
    @tagNames = []
  end
end
