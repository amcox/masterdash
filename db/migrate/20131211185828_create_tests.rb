class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :name
      t.string :subjects, array: true, default: []
      t.string :score_columns, array: true, default: []
      t.integer :order
      t.integer :year

      t.timestamps
    end
  end
end
