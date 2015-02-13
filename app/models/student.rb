class Student < ActiveRecord::Base
  has_many :enrollments
  has_many :scores, dependent: :destroy
  has_many :teachers, through: :enrollments
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    student_numbers = []
    
    # Loop through all students in the import and create or modify in the DB.
    progressbar = ProgressBar.create(:title => "Student Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    csv.each do |row|
      student_numbers.push row[:student_number].to_i
      student = Student.where(student_number: row[:student_number]).first_or_create
      student.update(name: row[:name], la_sped: row[:la_sped], current_school: row[:current_school],
        iep_speech_only: row[:iep_speech_only], state_test_ela: row[:state_test_ela],
        state_test_math: row[:state_test_math], state_test_sci: row[:state_test_sci],
        state_test_soc: row[:state_test_soc], state_grade: row[:state_grade].to_i
      )
      progressbar.increment
    end
    progressbar.finish
    
    # Loop through all students in the DB and delete the ones that were not in the import.
    progressbar = ProgressBar.create(:title => "Student Cleanup",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    Student.all.each do |db_student|
      if !student_numbers.include?(db_student.student_number)
        db_student.destroy
      end
      progressbar.increment
    end
    progressbar.finish
  end
  
  def grade_in_words
    case state_grade
    when -1
      "Pre-Kindergarten"
    when 0
      "Kindergarten"
    else
      "#{state_grade.ordinalize} Grade"
    end
  end

end
