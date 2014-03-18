class Score < ActiveRecord::Base
  belongs_to :student
  belongs_to :test
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    progressbar = ProgressBar.create(:title => "Score Import",
                    :starting_at => 0, :total => csv.length,
                    :format => '%e %B %p%% %t'
    )
    rows_not_created = []
    csv.each do |row|
      test = Test.where(name: row[:test], year: row[:year]).first
      student = Student.where(student_number: row[:student_number]).first
      if test && student
        score = Score.where(student_id: student.id, test_id: test.id, subject: row[:subject], year: row[:year]).first_or_create
        test.score_columns.each do |column_name|
          score.send("#{column_name.to_s}=", row[column_name.to_sym])
        end
        score.save
      else
        row << test.nil?
        row << student.nil?
        rows_not_created << row
      end
      progressbar.increment
    end
    rows_not_created.each do |r|
      progressbar.log r
    end
    progressbar.finish
  end
end
