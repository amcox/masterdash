class AddBasicStudentFields < ActiveRecord::Migration
  def change
  	add_column :students, :email, :string
  	add_column :students, :uid, :integer
  	add_column :students, :dob, :date
  	add_column :students, :gender, :string
  end
end
