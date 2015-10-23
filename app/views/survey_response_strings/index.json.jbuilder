json.array!(@survey_response_strings) do |survey_response_string|
  json.extract! survey_response_string, :id, :text, :response_value, :response_type
  json.url survey_response_string_url(survey_response_string, format: :json)
end
