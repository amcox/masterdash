json.array!(@observations) do |observation|
  json.extract! observation, :id, :teacher_id, :score, :date, :observer, :quarter, :small_school, :year
  json.url observation_url(observation, format: :json)
end
