require_relative './config'
require_relative '../model/model'
require_relative '../module/ss_evernote'

class Webcrip
  include SsEvernote

  def initialize
    favorites = Favorite.all
    favorites.each do |f|
      title = f.title
      url = f.url
      if f.evernote == 0
        tags = []
        f.tags.each do |tag|
          tags.push(tag.name)
        end
        kind = 'standard'
        flag = 0
        puts "Clip #{title}"
        `chrome-cli open #{url}`
        begin
          `cliclick -f cliclick/#{kind}`
          evernote(url, tags)
          unless @webclip
            puts "Retry webclip"
            kind = 'retry'
            raise
          end
        rescue
          if flag == 0
            puts "Retry webclip"
            retry
          else
            puts "Could not done webclip"
            next
          end
          flag = 1
        end
        `chrome-cli close`
        f.evernote = 1
        f.save
        puts "Done #{title} webclip"
      end
    end
  end

  def evernote(url, tags)
    @noteStore = setupNoteStore
    notebook = getNotebook('0002 Evernote')
    noteGuid = getNotes(notebook).last.guid
    note = ssGetNote(noteGuid)
    if note.attributes.sourceURL == url
      @webclip = true
      note.tagNames = tags
      # Automation note management
      # notebook = getNotebookByTagname(tags.first)
      # note.notebookGuid = notebook.guid
      @noteStore.updateNote(note)
      puts "Update #{note.title} tags"
    else
      @webclip = false
    end
  end
end
Webcrip.new
