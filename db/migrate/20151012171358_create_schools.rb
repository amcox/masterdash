class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.text :name
      t.text :abbreviation
      t.integer :state_id
      t.text :street

      t.timestamps
    end
  end
end
