class Formatter
  def self.percent_format(number)
    if number
      "#{(number * 100).round}%"
    end
  end
  
  def self.achievement_level_long(al_short)
    case al_short
    when "U"
      "Unsatisfactory"
    when "AB"
      "Approaching Basic"
    when "B"
      "Basic"
    when "M"
      "Mastery"
    when "A"
      "Advanced"
    when "PF"
      "Pre-Foundational"
    when "F"
      "Foundational"
    when "AB2"
      "Approaching Basic"
    when "B2"
      "Basic"
    when "WTS"
      "Working Toward Standards"
    when "MS"
      "Meets Standards"
    when "ES"
      "Exceeds Standards"
    else
      nil
    end
  end
  
  def self.subject_long(subject)
    case subject
    when "ela"
      "ELA"
    when "math"
      "Math"
    when "sci"
      "Science"
    when "soc"
      "Social Studies"
    else
      nil
    end
  end
  
end