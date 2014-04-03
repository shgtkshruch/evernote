require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  # "database" => "./model/favorite.db"
  "database" => "./model/all.db"
)

class Favorite < ActiveRecord::Base
  has_many :tags
end

class Tag < ActiveRecord::Base
  belongs_to :favorite
end

class Mymodel
  def insertData(nodes)
    @isUpdate = ''
    nodes.each do |node|
      if Favorite.find_by_url(node[:link])
        @isUpdate = true
        next
      else
        favorite = Favorite.new do |f|
          f.title = node[:title]
          f.url = node[:link]
        end
        favorite.save

        node[:tags].each do |tag|
          tag = Tag.new do |t|
            t.favorite_id = favorite.id
            t.name = tag
          end
          tag.save
        end
      end
    end

    def isUpdate?
      @isUpdate
    end
  end
end
