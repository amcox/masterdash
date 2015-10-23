class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      
      t.text :text
      t.text :survey_type
      t.text :response_type

      t.timestamps
    end
  end
end
