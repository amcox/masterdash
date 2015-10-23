json.array!(@survey_questions) do |survey_question|
  json.extract! survey_question, :id, :text, :survey_type, :response_type
  json.url survey_question_url(survey_question, format: :json)
end
