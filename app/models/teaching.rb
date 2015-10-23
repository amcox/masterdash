class Teaching < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :year
  has_and_belongs_to_many :schools
  has_and_belongs_to_many :enrollments
  has_many :observations
  has_many :vams
  has_many :survey_responses, through: :enrollments

end
