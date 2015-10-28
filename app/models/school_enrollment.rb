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
    rows_not_created = []
    csv.each do |row|
      student = Student.where(student_number: row[:student_number]).first
      school = School.where(abbreviation: row[:school_abb]).first
      year = Year.where(year: row[:year]).first

      if student && school && year
        # Create a new school_enrollment, because we earlier deleted all
        school_enrollment = SchoolEnrollment.create(student_id: student.id, 
        	school_id: school.id, year_id: year.id, grade: row[:grade], 
        	entrydate: row[:entry_date], exitdate: row[:exit_date],
        	laa1: row[:laa1], la_sped: row[:la_sped]
        )
      else
        # Indicate which missing object caused the failure and
        # add that row to the failed rows export
        row << student.nil?
        row << school.nil?
        row << year.nil?
        rows_not_created << row
      end
            
      progressbar.increment
    end
    # Display the failed rows
    rows_not_created.each do |r|
      progressbar.log r
    end
    
    progressbar.finish
  end

end
