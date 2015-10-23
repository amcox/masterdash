class CreateSurveyResponseStrings < ActiveRecord::Migration
  def change
    create_table :survey_response_strings do |t|
      
      t.text :text
      t.integer :response_value
      t.text :response_type

      t.timestamps
    end
  end
end
