require_relative './config'
require_relative '../model/model'
require_relative '../module/ss_evernote'

class Webcrip
  include SsEvernote

  def initialize
    favorites = Favorite.all
    favorites.each do |f|
      if f.evernote == 0
        tags = []
        f.tags.each do |tag|
          tags.push(tag.name)
        end
        kind = 'standard'
        flag = 0
        begin
          puts "Clip #{f.url}"
          `chrome-cli open #{f.url}`
          `cliclick -f cliclick/#{kind}`
          `chrome-cli close`
          evernote(f.url, tags)
          unless @webclip
            puts "Retry webclip"
            kind = 'retry'
            raise
          end
        rescue
          if flag == 0
            retry
          else
            puts "Could not done webclip"
            next
          end
          flag = 1
        end
        exit 1
        f.evernote = 1
        f.save
      end
    end
  end

  def evernote(url, tags)
    @noteStore = setupNoteStore
    notebook = getNotebook('0002 Evernote')
    noteGuid = getNotes(notebook).last.guid
    note = ssGetNote(noteGuid)
    if note.attributes.sourceURL == url
      puts "Update #{note.title} tags"
      @webclip = true
      note.tagNames = tags
      @noteStore.updateNote(note)
    else
      @webclip = false
    end
  end
end
Webcrip.new
