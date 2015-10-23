class CreateSurveyResponses < ActiveRecord::Migration
  def change
    create_table :survey_responses do |t|

      t.references :survey_questions, index: true
      t.integer :response_value
      t.references :enrollments, index: true

      t.timestamps
    end
  end
end
