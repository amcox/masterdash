class Enrollment < ActiveRecord::Base
  belongs_to :student
  has_and_belongs_to_many :teachings
  has_many :teachers, through: :teachings
  belongs_to :school
  belongs_to :year
  belongs_to :school_enrollment
  
  
  def scores
    self.student.scores.where("scores.subject = ?", self.subject) 
  end


  def self.import(file_path)
    require 'csv'
    
    Enrollment.delete_all
    
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    progressbar = ProgressBar.create(:title => "Enrollment Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    errs = []
    saved_count = 0
    csv.each do |row|
      teacher = Teacher.where(email: row[:teacher_email]).first
      year = Year.where(ending_year: row[:year]).first
      if teacher && year
        teaching = Teaching.where(teacher_id: teacher.id).where(year_id: year.id).first
      end
      student = Student.where(student_number: row[:student_number]).first
      school = School.where(abbreviation: row[:school]).first
      school_enrollment = student.school_enrollments.where("entrydate <= :entry_date AND exitdate >= :exit_date",
        {entry_date: row[:entry_date], exit_date: row[:exit_date]}
      ).last
      if student && teacher && year && teaching && school && school_enrollment
        enrollment = Enrollment.create(student_id: student.id,
          subject: row[:subject], section: row[:section], class_type: row[:class_type],
          entry: row[:entry_date], exit: row[:exit_date], cohort: row[:cohort],
          year: year, school: school, school_enrollment: school_enrollment
        )
        teaching.enrollments << enrollment
        saved_count += 1
      else
        row << !student.nil?
        row << !teacher.nil?
        row << !year.nil?
        row << !teaching.nil?
        row << !school.nil?
        row << !school_enrollment.nil?        
        errs << row
      end
      progressbar.increment
    end
    progressbar.finish
    
    headers_with_flags = headers + ['student?', 'teacher?', 'year?', 'teaching?', 'school?', 'school_enrollment?']
    
    if errs.any?
      errFile ="enrollments_errors_#{Date.today.strftime('%d%b%y')}.csv"
      errs.insert(0, headers_with_flags)
      errs.insert(0, ["The following #{errs.length - 1} enrollments were not saved due to the errors noted. #{saved_count} others were saved successfully."])
      CSV.open("csvs/#{errFile}", "wb") do |csv|
        errs.each do |r|
          csv << r
        end
      end
    end
    
  end
  
  def self.unique_sections
    select("school, teacher_id, subject, section").distinct.order(:section).
    order(:teacher_id).order(:subject).order(:school)
  end
end
