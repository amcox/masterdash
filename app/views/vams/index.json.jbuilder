json.array!(@vams) do |vam|
  json.extract! vam, :id, :subject, :teaching_id, :percentile
  json.url vam_url(vam, format: :json)
end
