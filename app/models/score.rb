class Score < ActiveRecord::Base
  belongs_to :student
  belongs_to :test
  belongs_to :year
  belongs_to :school_enrollment
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    progressbar = ProgressBar.create(:title => "Score Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    errs = []
    saved_count = 0
    csv.each do |row|
      test = Test.where(name: row[:test]).first
      year = Year.where(ending_year: row[:year]).first
      student = Student.where(student_number: row[:student_number]).first
      
      if !student.nil?
        this_school_enrollment = student.school_enrollments.where("entrydate <= :test_import_date AND exitdate >= :test_import_date",
          {test_import_date: row[:date]}
        ).last
      end

      if test && student && year && this_school_enrollment
        score = Score.where(student_id: student.id, test_id: test.id, year_id: year.id, subject: row[:subject], grade: row[:grade]).first_or_create
        test.score_columns.each do |column_name|
          score.send("#{column_name.to_s}=", row[column_name.to_sym])
        end
        score.school_enrollment = this_school_enrollment
        score.save
        saved_count += 1
      else
        row << !student.nil?
        row << !test.nil?
        row << !year.nil?
        row << !this_school_enrollment.nil?
        errs << row
      end
      progressbar.increment
    end
  
    progressbar.finish
    
    headers = csv.first.headers
    headers_with_flags = headers + ['student?', 'test?', 'year?', 'school_enrollment?']
    
    if errs.any?
      errFile ="scores_errors_#{Time.now.strftime('%F-%H%M%S')}.csv"
      errs.insert(0, headers_with_flags)
      errs.insert(0, ["The following #{errs.length - 1} scores were not saved due to the errors noted. #{saved_count} others were saved successfully."])
      CSV.open("csvs/#{errFile}", "wb") do |csv|
        errs.each do |r|
          csv << r
        end
      end
    end




  end
end
