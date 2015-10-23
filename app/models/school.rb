class School < ActiveRecord::Base
	has_and_belongs_to_many :teachings
	has_many :teachers, through: :teachings
	has_many :enrollments
	has_many :school_enrollments
	
end
