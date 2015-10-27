class UpdateUiDdatatype < ActiveRecord::Migration
  
  	def self.up
    change_column :students, :uid, :bigint
  	end
 

end
