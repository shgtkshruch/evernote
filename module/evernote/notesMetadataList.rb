require 'evernote_oauth'

class Evernote::EDAM::NoteStore::NotesMetadataList
  def hasNote?
    noteNum = self.notes.length
    case noteNum
    when 0
      puts "Not found note"
      exit 1
    when 1
      puts "Get #{noteNum} note"
    else 
      puts "Get #{noteNum} notes"
    end
  end
end

