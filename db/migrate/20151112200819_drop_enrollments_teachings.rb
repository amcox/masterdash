class DropEnrollmentsTeachings < ActiveRecord::Migration
  def change
  
  	drop_table :enrollments_teachings

  end
end
