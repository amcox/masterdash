class CreateVams < ActiveRecord::Migration
  def change
    create_table :vams do |t|
      t.text :subject
      t.references :teaching, index: true
      t.decimal :percentile

      t.timestamps
    end
  end
end
