json.array!(@instructings) do |instructing|
  json.extract! instructing, :id, :enrollment_id, :teaching_id, :start_date, :end_date, :lead
  json.url instructing_url(instructing, format: :json)
end
