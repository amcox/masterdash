class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.references :teacher, index: true
      t.decimal :score
      t.date :date
      t.string :observer
      t.integer :quarter
      t.string :small_school
      t.integer :year

      t.timestamps
    end
  end
end
