class CreateSchoolEnrollments < ActiveRecord::Migration
  def change
    create_table :school_enrollments do |t|
      t.references :student, index: true
      t.references :school, index: true
      t.references :year, index: true
      t.integer :grade
      t.date :entrydate
      t.date :exitdate
      t.boolean :laa1
      t.integer :la_sped

      t.timestamps

    end
   
    remove_column :enrollments, :grade, :integer
    add_column :enrollments, :school_enrollment_id, :integer

    remove_column :students, :la_sped, :integer
    remove_column :students, :state_test_ela, :string
    remove_column :students, :state_test_math, :string
    remove_column :students, :state_test_sci, :string
    remove_column :students, :state_test_soc, :string
    remove_column :students, :current_school, :string

    remove_column :students, :state_grade, :integer
    remove_column :students, :iep_speech_only, :boolean

    add_column :scores, :school_enrollment_id, :integer

  end
end

