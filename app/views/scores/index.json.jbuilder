json.array!(@scores) do |score|
  json.extract! score, :id, :student_id, :test_id, :subject, :achievement, :ai_points, :scaled_score, :percentile, :percent, :on_level, :gap, :growth_goal, :previous_growth_goal, :string, :year
  json.url score_url(score, format: :json)
end
