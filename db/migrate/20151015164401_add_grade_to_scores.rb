class AddGradeToScores < ActiveRecord::Migration
  def change
  
  	add_column :scores, :grade, :integer


  end
end
