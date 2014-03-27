# Get tag guid by tag name
def getTag(noteStore, tagName)
  tagGuid = ""

  begin
    listTags = noteStore.listTags 
    listTags.each do |tag|
      if tag.name === tagName
        tagGuid = tag.guid
      end
    end

  rescue Evernote::EDAM::Error::EDAMUserException => edus
    puts "EDAMUserException: #{edus.errorCode} #{edus.parameter}"
  rescue Evernote::EDAM::Error::EDAMSystemException => edsy
    puts "EDAMSystemException: #{edsy}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => edno
    puts "EDAMNotFoundException: #{edno}"
  end

  tagGuid
end

def delete_note(noteStore, guids)
    guids.each do |guid|
      noteStore.deleteNote(guid)
    end
end

# Make new note
def make_note(noteStore, note_title, note_body)
  n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  n_body += "<en-note>#{note_body}</en-note>"
 
  ## Create note object
  our_note = Evernote::EDAM::Type::Note.new
  our_note.title = note_title
  our_note.content = n_body
 
  ## Attempt to create note in Evernote account
  note = noteStore.createNote(our_note)
 
  ## Return created note object
  note
end

def updateNote(noteStore, noteGuid, noteTitle, noteBody)
  n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
  n_body += "<en-note>#{noteBody}</en-note>"

  our_note = Evernote::EDAM::Type::Note.new
  our_note.guid = noteGuid
  our_note.title = noteTitle
  our_note.content = n_body

  begin
    note = noteStore.updateNote(our_note)

  rescue Evernote::EDAM::Error::EDAMUserException => edue
    puts "EDAMUserException: #{edue.errorCode} #{edue.parameter}"
  end

  note
end
