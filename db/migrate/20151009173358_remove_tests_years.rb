class RemoveTestsYears < ActiveRecord::Migration
  def change
  
  	drop_table :tests_years

  	add_column :scores, :test_id, :integer
  	add_column :scores, :year_id, :integer

  end
end
