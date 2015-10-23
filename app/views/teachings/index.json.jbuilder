json.array!(@teachings) do |teaching|
  json.extract! teaching, :id, :teacher_id, :year_id, :level, :summative_rating
  json.url teaching_url(teaching, format: :json)
end
