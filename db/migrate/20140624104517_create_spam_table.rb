class CreateSpamTable < ActiveRecord::Migration
  
   def change

    create_table :spams do |t|
      t.string "query"
      t.string "user"
      t.string "author"
      t.text "post"

      t.timestamps
  	end
  end

end
