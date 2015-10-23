class AddEnrollmentsTeachingsTable < ActiveRecord::Migration
  def change
  	
  create_table :enrollments_teachings, id: false do |t|
      t.belongs_to :enrollment, index: true
      t.belongs_to :teaching, index: true
  end

  remove_column :enrollments, :teacher_id, :integer
  remove_column :enrollments, :year, :integer
  remove_column :enrollments, :school, :string
  add_column :enrollments, :year_id, :integer
  add_column :enrollments, :school_id, :integer

  end
end
