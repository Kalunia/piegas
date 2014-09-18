class AddAntispamFeature < ActiveRecord::Migration
  def change

  	change_table(:users) do |t|
  		
  		t.integer "anti_spam", :default => 0
  	end
  end
end
