class Year < ActiveRecord::Base
	has_many :teachings
	has_many :teachers, through: :teachings
	has_many :enrollments
	has_many :school_enrollments

  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    
    csv.each do |row|
      
     
      # year = Year.create (year: year, ending_year: ending_year)

    end
  	
  end

end
