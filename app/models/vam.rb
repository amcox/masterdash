class Vam < ActiveRecord::Base
  belongs_to :teaching

  def teacher
  	teaching.teacher  	
  end

end
