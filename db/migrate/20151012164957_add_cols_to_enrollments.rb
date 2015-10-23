class AddColsToEnrollments < ActiveRecord::Migration
  def change
  
  	add_column :enrollments, :entry, :date
	add_column :enrollments, :exit, :date
	add_column :enrollments, :cohort, :string
	add_column :enrollments, :credit_potential, :decimal
	add_column :enrollments, :credit_earned, :decimal

  end
end
