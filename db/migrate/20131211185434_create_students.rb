class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.integer :student_number
      t.string :name
      t.integer :la_sped
      t.boolean :iep_speech_only
      t.string :state_test_ela
      t.string :state_test_math
      t.string :state_test_sci
      t.string :state_test_soc
      t.string :current_school
      t.integer :state_grade

      t.timestamps
    end
  end
end
