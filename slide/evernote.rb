require 'evernote_oauth'
require "mime/types"
require "base64"
require './config.rb'
require '../config/token.rb'
require '../module/base.rb'

class Slidenote
  include Base

  def initialize
    setupNoteStore
  end

  def getNotebookGuid(notebookName)
    getNotebookGuid(notebookName)
  end

  def createNote
    createNote(title, content, notebookGuid, url, filename)
  end
end
