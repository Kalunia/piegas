class CreateFavoritedTable < ActiveRecord::Migration
    
   def change

    create_table :favoriteds do |t|
      t.string "query"
      t.string "user"
      t.string "author"
      t.text "post"
      t.integer "sentiment", :default => 0

      t.timestamps
    end
  end

end
