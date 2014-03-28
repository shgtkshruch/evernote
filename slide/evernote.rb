require '../config/token.rb'
require '../module/base.rb'

class Slidenote
  include Base

  def initialize
    @noteStore = setupNoteStore
  end

  def createNote(note)
    @noteStore.createNote(note)
  end
end

