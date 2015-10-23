json.array!(@schools) do |school|
  json.extract! school, :id, :name, :abbreviation, :state_id, :street
  json.url school_url(school, format: :json)
end
