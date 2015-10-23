class SchoolEnrollment < ActiveRecord::Base
  belongs_to :student
  belongs_to :school
  belongs_to :year
  has_many :scores
  has_many :enrollments

 def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    
    SchoolEnrollment.delete_all
    
    progressbar = ProgressBar.create(:title => "SchoolEnrollment Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    csv.each do |row|
      student = Student.where(student_number: row[:student_number]).first
      school = School.where(abbreviation: row[:school]).first
      year = Year.where(ending_year: row[:ending_year]).first

      school_enrollment = SchoolEnrollment.create(student_id: student.id, 
      	school_id: school.id, year_id: year.id, grade: row[:grade_level], 
      	entrydate: row[:entrydate], exitdate: row[:exitdate],
      	laa1: row[:laa1], la_sped: row[:la_sped]

      )
   
      progressbar.increment
    end
    progressbar.finish
    
  end

end
