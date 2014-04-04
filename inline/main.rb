require_relative './config'
require_relative '../module/ss_evernote'
require_relative '../module/mynote'

class  Iniline
  include SsEvernote

  def initialize
    @filename = 'foo.txt'
    evernote
    sed
    f = `cat #{@filename}`
    update(f)
  end

  def evernote
    @noteStore = setupNoteStore
    notebook = getNotebook(SEARCHNOTEBOOK)
    notes = getNotes(notebook)
    noteGuid = notes.last.guid
    @note = ssGetNote(noteGuid)

    File.open(@filename, 'w') do |file|
      file.puts(@note.content)
    end
  end

  def sed
    `gsed -i 's/<p>/<p style="font-family:Helvetica;font-size:14px;">/g' #{@filename}`
    `gsed -i 's/<en-note.*/&<div style="width:780px;margin-left:auto;margin-right:auto;">/g' #{@filename}`
    `gsed -i 's/<\\/en-note>/<\\/div>&/g' #{@filename}`
  end

  def update(content)
    @note.content = content
    puts "Update note..."
    ssUpdateNote(@note)
  end
end
Iniline.new
