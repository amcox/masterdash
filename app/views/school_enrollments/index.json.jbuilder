json.array!(@school_enrollments) do |school_enrollment|
  json.extract! school_enrollment, :id, :student_id, :school_id, :year_id, :grade, :entrydate, :exitdate
  json.url school_enrollment_url(school_enrollment, format: :json)
end
