class AddSchoolsTeachingsTable < ActiveRecord::Migration
  def change
  
   create_table :schools_teachings, id: false do |t|
      t.belongs_to :school, index: true
      t.belongs_to :teaching, index: true
   end
  end
end
