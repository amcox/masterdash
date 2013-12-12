# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131211190122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "enrollments", force: true do |t|
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.string   "subject"
    t.integer  "grade"
    t.integer  "year"
    t.string   "school"
    t.boolean  "current"
    t.boolean  "fay"
    t.string   "section"
    t.string   "class_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrollments", ["student_id"], name: "index_enrollments_on_student_id", using: :btree
  add_index "enrollments", ["teacher_id"], name: "index_enrollments_on_teacher_id", using: :btree

  create_table "observations", force: true do |t|
    t.integer  "teacher_id"
    t.decimal  "score"
    t.date     "date"
    t.string   "observer"
    t.integer  "quarter"
    t.string   "small_school"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "observations", ["teacher_id"], name: "index_observations_on_teacher_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "student_id"
    t.integer  "test_id"
    t.string   "subject"
    t.string   "achievement_level"
    t.integer  "ai_points"
    t.integer  "scaled_score"
    t.decimal  "percentile"
    t.decimal  "percent"
    t.boolean  "on_level"
    t.decimal  "gap"
    t.decimal  "growth_goal"
    t.decimal  "previous_growth_goal"
    t.string   "round"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["student_id"], name: "index_scores_on_student_id", using: :btree
  add_index "scores", ["test_id"], name: "index_scores_on_test_id", using: :btree

  create_table "students", force: true do |t|
    t.integer  "student_number"
    t.string   "name"
    t.integer  "la_sped"
    t.boolean  "iep_speech_only"
    t.string   "state_test_ela"
    t.string   "state_test_math"
    t.string   "state_test_sci"
    t.string   "state_test_soc"
    t.string   "current_school"
    t.integer  "state_grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", force: true do |t|
    t.string   "teacher_number"
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", force: true do |t|
    t.string   "name"
    t.string   "subjects",      default: [], array: true
    t.string   "score_columns", default: [], array: true
    t.integer  "order"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
