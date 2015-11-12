class CreateInstructings < ActiveRecord::Migration
  def change
    create_table :instructings do |t|
      t.references :enrollment, index: true
      t.references :teaching, index: true
      t.date :start_date
      t.date :end_date
      t.boolean :lead

      t.timestamps
    end
  end
end
