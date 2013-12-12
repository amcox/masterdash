class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :teacher_number
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
