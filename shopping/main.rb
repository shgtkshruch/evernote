require_relative './config'
require_relative '../module/ss_evernote'

class ShoppingNotes
  include SsEvernote

  def initialize
    @src = '0000 inbox'
    @author = 'service-jp@paypal.com'
    # @author = 'O\'Reilly Japan Ebook Store'
    vendors
    getShoppingNotes
    setDestNotebook
  end

  def vendors
    @vendors = {
      'amazon' => '1501 Amazon', 
      'オライリー・ジャパン' => '1502 OReilly',
      'bookoff' => '1503 Bookoff',
      'appple' => '1504 Apple',
      'gihyo' => '1505 Gihyo',
      'tatsu-zin' => '1506 Tatsuzin'
    }
  end

  def getShoppingNotes
    @noteStore = setupNoteStore
    @src_notebook = getNotebook(@src)
    @notes_meta = getNotes(@src_notebook, '支払')
    hasNote? ? foundNote : notFound
  end

  def hasNote?
    @notes_meta.empty? ? false : true
  end

  def foundNote
    puts "#{@notes_meta.length} notes"
  end

  def notFound
    puts "Not found"
    exit 1
  end

  def setDestNotebook
    @notes_meta.each do |note_meta|
      @note = ssGetNote(note_meta.guid)
      @vendors.each do |vendor, notebook| 
        if @note.title.include?(vendor.to_s)
          @dest_notebook = getNotebook(notebook.to_s)
        else
          @dest_notebook = getNotebook('1500 Shopping')
        end
      end
      moveNotes
    end
  end

  def moveNotes
    unless @note.attributes.author.nil?
      if @note.attributes.author.include?(@author)
        @note.notebookGuid = @dest_notebook.guid
        ssUpdateNote(@note)
        puts "Move #{@note.title} from [#{@src}] to [#{@dest_notebook.name}]"
      end
    end
  end
end

ShoppingNotes.new
