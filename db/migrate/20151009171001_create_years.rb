class CreateYears < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.text :year
      t.integer :ending_year

      t.timestamps
    end

    create_table :tests_years do |t|
      t.belongs_to :test, index: true
      t.belongs_to :year, index: true

      t.timestamps
    end



  end
end
