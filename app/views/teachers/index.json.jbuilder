json.array!(@teachers) do |teacher|
  json.extract! teacher, :id, :teacher_number, :name, :active
  json.url teacher_url(teacher, format: :json)
end
