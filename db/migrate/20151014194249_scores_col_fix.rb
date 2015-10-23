class ScoresColFix < ActiveRecord::Migration
  def change
  
  	remove_column :scores, :tests_years_id, :integer

  end
end
