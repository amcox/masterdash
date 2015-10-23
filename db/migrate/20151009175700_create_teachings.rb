class CreateTeachings < ActiveRecord::Migration
  def change
    create_table :teachings do |t|
      t.references :teacher, index: true
      t.references :year, index: true
      t.string :level
      t.decimal :summative_rating

      t.timestamps
    end
  end
end
