class Observation < ActiveRecord::Base
  belongs_to :teacher
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    csv.each do |row|
      teacher = Teacher.find(teacher_number: row[:teacher_number])
      if teacher
        observation = Observation.find_or_create(teacher_id: teacher.id, quarter: row[:quarter], year: row[:year])
        observation.small_school = row[:small_school]
        observation.observer = row[:observer]
        observation.date = row[:date]
        observation.score = row[:score]
        observation.save
      else
        teacher = Teacher.create(teacher_number: row[:teacher_number], name: row[:teacher_name])
        observation = Observation.find_or_create(teacher_id: teacher.id, quarter: row[:quarter], year: row[:year])
        observation.small_school = row[:small_school]
        observation.observer = row[:observer]
        observation.date = row[:date]
        observation.score = row[:score]
        observation.save
      end
    end
  end
end
