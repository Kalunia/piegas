class CreateProducts < ActiveRecord::Migration
  
  def up
    create_table :tweets do |t|
      t.string "product"
      t.string "author"
      t.text "post"
      t.integer "sentiment", :default => 0

      t.timestamps
    end
  end

  def down
  	drop_table :tweets
  end
  
end
