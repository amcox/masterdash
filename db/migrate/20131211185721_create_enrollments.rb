class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.references :student, index: true
      t.references :teacher, index: true
      t.string :subject
      t.integer :grade
      t.integer :year
      t.string :school
      t.boolean :current
      t.boolean :fay
      t.string :section
      t.string :class_type

      t.timestamps
    end
  end
end
