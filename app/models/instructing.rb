class Instructing < ActiveRecord::Base
  belongs_to :enrollment
  belongs_to :teaching
end
