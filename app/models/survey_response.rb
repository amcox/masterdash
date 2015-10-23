class SurveyResponse < ActiveRecord::Base
	belongs_to :enrollment
	belongs_to :survey_question
end
