json.array!(@enrollments) do |enrollment|
  json.extract! enrollment, :id, :student_id, :teacher_id, :subject, :grade, :year, :school, :current, :fay, :section, :class_type
  json.url enrollment_url(enrollment, format: :json)
end
