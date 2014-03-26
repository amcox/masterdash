class Observation < ActiveRecord::Base
  belongs_to :teacher
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    csv.each do |row|
      teacher = Teacher.where(teacher_number: row[:teacher_number]).first
      if teacher
        observation = Observation.where(teacher_id: teacher.id, quarter: row[:quarter], year: row[:year]).first_or_create
        observation.small_school = row[:school]
        observation.observer = row[:observer]
        observation.date = row[:date]
        observation.score = row[:score]
        observation.save
      else
        teacher = Teacher.create(teacher_number: row[:teacher_number], name: row[:teacher_name])
        observation = Observation.where(teacher_id: teacher.id, quarter: row[:quarter], year: row[:year]).first_or_create
        observation.small_school = row[:school]
        observation.observer = row[:observer]
        observation.date = row[:date]
        observation.score = row[:score]
        observation.save
      end
    end
  end
end
