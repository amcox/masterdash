class AddColsToScores < ActiveRecord::Migration
  def change
    add_column :scores, :winter_spring_gg, :decimal	
    add_column :scores, :fall_winter_gg, :decimal
    add_column :scores, :fall_spring_gg, :decimal
	
	add_column :scores, :ge, :decimal
	add_column :scores, :nce, :decimal
	add_column :scores, :se, :decimal	

    add_column :scores, :vam_expected_ss, :integer
    add_column :scores, :date, :date

    remove_column :scores, :year
    remove_column :scores, :test_id
    remove_column :scores, :round

    add_column :scores, :tests_years_id, :integer
  end
end
