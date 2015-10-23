class UpdateObservationsSchema < ActiveRecord::Migration
  def change
  
  remove_column :observations, :teacher_id, :integer
  remove_column :observations, :year, :integer
  add_column :observations, :teaching_id, :integer

  end
end
