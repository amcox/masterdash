class School < ActiveRecord::Base
	has_and_belongs_to_many :teachings
	has_many :teachers, through: :teachings
	has_many :enrollments
	has_many :school_enrollments
  
  def self.import(file_path)
    require 'csv'
    infile = File.read(file_path)
    csv = CSV.parse(infile, {:headers => true, :header_converters => :symbol})
    csv.each do |row|
      school = School.create(name: row[:name], abbreviation: row[:abbreviation],
        state_id: row[:state_id], street: row[:address]
      )
    end	
  end
  
end
