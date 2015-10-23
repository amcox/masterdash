class RemoveYearFromTests < ActiveRecord::Migration
  def change

  	remove_column :tests, :year


  end
end
