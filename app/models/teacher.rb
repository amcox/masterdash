class Teacher < ActiveRecord::Base
  has_many :enrollments
  has_many :students, through: :enrollments
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    csv.each do |row|
      teacher = Teacher.where(teacher_number: row[:teacher_number]).first_or_create
      teacher.update(name: row[:teacher_name], active: true)
    end
  end
  
end
