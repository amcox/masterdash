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
    Score.
    joins("INNER JOIN enrollments ON enrollments.student_id = scores.student_id AND enrollments.subject = scores.subject").
    joins("INNER JOIN instructings ON enrollments.id = instructings.enrollment_id").
    joins("INNER JOIN teachings ON instructings.teaching_id = teachings.id").
    joins("INNER JOIN teachers ON teachings.teacher_id = teachers.id").
    joins("INNER JOIN tests ON scores.test_id = tests.id").
    where("teachers.id = ?", self.id)
  end

  def scores_fay
    self.scores.where("teachings.start_date <= to_date('2015-10-01') AND 
      teachings.end_date >= to_date('2016-05-01')")
    #TO-DO: Hard-coded for 15-16; to use multiple years add fay_start and fay_end to years
    #Then add years join to scores SQL query above 
  end

  def scores_with_ai
    self.scores.where("scores.ai_points IS NOT NULL").includes(:test)
  end
  
  def ai_by_test
    Score.calculate_ai_by_test(self.scores_with_ai)
  end
  
  def network_comparison_ai_by_test
    network_scores = self.scores_with_ai.map{|s| {grade: s.grade, subject: s.subject}}.uniq.map do |combo|
     Score.where("grade = ? AND subject = ? AND ai_points IS NOT NULL", combo[:grade], combo[:subject]).includes(:test)
    end
    network_scores.flatten!
    Score.calculate_ai_by_test(network_scores)
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
