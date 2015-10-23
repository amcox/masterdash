class SurveyQuestion < ActiveRecord::Base
	has_many :survey_responses

	def survey_response_strings
		SurveyResponseString.where("response_type = ?", response_type)
	end

end
