class Teacher < ActiveRecord::Base
  has_many :teachings
  has_many :years, through: :teachings
  has_many :schools, through: :teachings
  has_many :enrollments, through: :teachings 
  has_many :students, through: :enrollments
  has_many :observations, through: :teachings
  has_many :vams, through: :teachings
  has_many :survey_responses, through: :teachings
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    headers = csv.first.headers
    progressbar = ProgressBar.create(:title => "Student Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    csv.each do |row|
      teacher = Teacher.where(teacher_number: row[:teacher_number]).first_or_create
      teacher.update(name: row[:teacher_name], active: true)
      progressbar.increment
    end
    progressbar.finish
  end
  

 def schools_in(y)

 end




end
