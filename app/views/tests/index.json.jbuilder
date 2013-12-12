json.array!(@tests) do |test|
  json.extract! test, :id, :name, :subjects, :score_columns, :order, :year
  json.url test_url(test, format: :json)
end
