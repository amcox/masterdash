class Test < ActiveRecord::Base
  has_many :scores
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    csv.each do |row|
      test = Test.find_or_create_by(name: row[:name])
      test.order = row[:order]
    #  test.year = row[:year]
      if row[:type] == 'leap'
        test.subjects = ['ela', 'math', 'sci', 'soc']
        test.score_columns = ['scaled_score', 'achievement_level', 'ai_points', 'on_level']
      elsif row[:type] == 'benchmark'
        test.subjects = ['ela', 'math', 'sci', 'soc']
        test.score_columns = ['percent', 'achievement_level', 'ai_points', 'on_level']
      elsif row[:type] == 'map'
        test.subjects = ['ela', 'math']
        test.score_columns = ['scaled_score', 'percentile', 'ai_points', 'on_level']
      elsif row[:type] == 'star'
        test.subjects = ['ela','math']
        test.score_columns = ['scaled_score', 'date', 'ge']
      end
      test.save
    end
  end
  
end
