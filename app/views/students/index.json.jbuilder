json.array!(@students) do |student|
  json.extract! student, :id, :student_number, :name, :la_sped, :iep_speech_only, :state_test_ela, :state_test_math, :state_test_sci, :state_test_soc, :current_school, :state_grade
  json.url student_url(student, format: :json)
end
