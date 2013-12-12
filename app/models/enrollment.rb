class Enrollment < ActiveRecord::Base
  belongs_to :student
  belongs_to :teacher
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    csv.each do |row|
      teacher = Teacher.where(teacher_number: row[:teacher_number]).first_or_create
      student = Student.where(student_number: row[:student_number]).first
      if student
        Enrollment.create(teacher_id: teacher.id, student_id: student.id, subject: row[:subject],
                          section: row[:section], grade: row[:grade], school: row[:school],
                          year: row[:this_year], current: row[:flag_current], fay: row[:fay], class_type: row[:class_type]
        )
      end
    end
  end
end
