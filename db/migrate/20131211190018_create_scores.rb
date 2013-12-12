class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.references :student, index: true
      t.references :test, index: true
      t.string :subject
      t.string :achievement_level
      t.integer :ai_points
      t.integer :scaled_score
      t.decimal :percentile
      t.decimal :percent
      t.boolean :on_level
      t.decimal :gap
      t.decimal :growth_goal
      t.decimal :previous_growth_goal
      t.string :round
      t.integer :year

      t.timestamps
    end
  end
end
