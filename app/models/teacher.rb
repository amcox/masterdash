class Teacher < ActiveRecord::Base
  has_many :teachings
  has_many :years, through: :teachings
  has_many :schools, through: :teachings
  has_many :enrollments, through: :teachings 
  has_many :students, through: :enrollments
  has_many :observations, through: :teachings
  has_many :vams, through: :teachings
  has_many :survey_responses, through: :teachings
  
  def scores
    self.enrollments.joins('LEFT OUTER JOIN students ON enrollments.student_id = students.id').
    joins('LEFT OUTER JOIN scores ON scores.student_id = students.id AND scores.subject = enrollments.subject').
    select('scores.*')
  end

  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    progressbar = ProgressBar.create(:title => "Teacher Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    csv.each do |row|
      # Check for uniqueness on email
      teacher = Teacher.where(email: row[:email_addr]).first_or_create
      
      # Update other fields
      teacher.update(name: row[:teacher_name], teacher_number: row[:renew_id], active: true)
      
      # For now, also create a teaching for the latest year. Must change for multi-year.
      teacher.teachings.create(year: Year.last)
      
      progressbar.increment
    end
    progressbar.finish
  end
  
 def schools_in(y)
 end
 
end
