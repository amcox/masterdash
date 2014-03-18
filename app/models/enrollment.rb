class Enrollment < ActiveRecord::Base
  belongs_to :student
  belongs_to :teacher
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    progressbar = ProgressBar.create(:title => "Enrollment Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    csv.each do |row|
      teacher = Teacher.where(teacher_number: row[:teacher_number]).first_or_create
      student = Student.where(student_number: row[:student_number]).first
      if student && teacher
        Enrollment.create(teacher_id: teacher.id, student_id: student.id, subject: row[:subject],
                          section: row[:section], grade: row[:grade], school: row[:school],
                          year: row[:this_year], current: row[:flag_current], fay: row[:fay], class_type: row[:class_type]
        )
      end
      progressbar.increment
    end
    progressbar.finish
  end
  
  def self.unique_sections
    select("school, teacher_id, subject, section").distinct.order(:section).
    order(:teacher_id).order(:subject).order(:school)
  end
end
