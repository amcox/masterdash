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

ActiveRecord::Schema.define(version: 20151112201402) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "enrollments", force: true do |t|
    t.integer  "student_id"
    t.string   "subject"
    t.boolean  "current"
    t.boolean  "fay"
    t.string   "section"
    t.string   "class_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "entry"
    t.date     "exit"
    t.string   "cohort"
    t.decimal  "credit_potential"
    t.decimal  "credit_earned"
    t.integer  "year_id"
    t.integer  "school_id"
    t.integer  "school_enrollment_id"
  end

  add_index "enrollments", ["student_id"], name: "index_enrollments_on_student_id", using: :btree

  create_table "instructings", force: true do |t|
    t.integer  "enrollment_id"
    t.integer  "teaching_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "lead"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructings", ["enrollment_id"], name: "index_instructings_on_enrollment_id", using: :btree
  add_index "instructings", ["teaching_id"], name: "index_instructings_on_teaching_id", using: :btree

  create_table "observations", force: true do |t|
    t.decimal  "score"
    t.date     "date"
    t.string   "observer"
    t.integer  "quarter"
    t.string   "small_school"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teaching_id"
  end

  create_table "school_enrollments", force: true do |t|
    t.integer  "student_id"
    t.integer  "school_id"
    t.integer  "year_id"
    t.integer  "grade"
    t.date     "entrydate"
    t.date     "exitdate"
    t.boolean  "laa1"
    t.integer  "la_sped"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_enrollments", ["school_id"], name: "index_school_enrollments_on_school_id", using: :btree
  add_index "school_enrollments", ["student_id"], name: "index_school_enrollments_on_student_id", using: :btree
  add_index "school_enrollments", ["year_id"], name: "index_school_enrollments_on_year_id", using: :btree

  create_table "schools", force: true do |t|
    t.text     "name"
    t.text     "abbreviation"
    t.integer  "state_id"
    t.text     "street"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools_teachings", id: false, force: true do |t|
    t.integer "school_id"
    t.integer "teaching_id"
  end

  add_index "schools_teachings", ["school_id"], name: "index_schools_teachings_on_school_id", using: :btree
  add_index "schools_teachings", ["teaching_id"], name: "index_schools_teachings_on_teaching_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "student_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "winter_spring_gg"
    t.decimal  "fall_winter_gg"
    t.decimal  "fall_spring_gg"
    t.decimal  "ge"
    t.decimal  "nce"
    t.decimal  "se"
    t.integer  "vam_expected_ss"
    t.date     "date"
    t.integer  "test_id"
    t.integer  "year_id"
    t.integer  "school_enrollment_id"
    t.integer  "grade"
  end

  add_index "scores", ["student_id"], name: "index_scores_on_student_id", using: :btree

  create_table "students", force: true do |t|
    t.integer  "student_number"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "uid",            limit: 8
    t.date     "dob"
    t.string   "gender"
  end

  create_table "survey_questions", force: true do |t|
    t.text     "text"
    t.text     "survey_type"
    t.text     "response_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_response_strings", force: true do |t|
    t.text     "text"
    t.integer  "response_value"
    t.text     "response_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_responses", force: true do |t|
    t.integer  "survey_questions_id"
    t.integer  "response_value"
    t.integer  "enrollments_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_responses", ["enrollments_id"], name: "index_survey_responses_on_enrollments_id", using: :btree
  add_index "survey_responses", ["survey_questions_id"], name: "index_survey_responses_on_survey_questions_id", using: :btree

  create_table "teachers", force: true do |t|
    t.string   "teacher_number"
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "teachings", force: true do |t|
    t.integer  "teacher_id"
    t.integer  "year_id"
    t.string   "level"
    t.decimal  "summative_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teachings", ["teacher_id"], name: "index_teachings_on_teacher_id", using: :btree
  add_index "teachings", ["year_id"], name: "index_teachings_on_year_id", using: :btree

  create_table "tests", force: true do |t|
    t.string   "name"
    t.string   "subjects",      default: [], array: true
    t.string   "score_columns", default: [], array: true
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vams", force: true do |t|
    t.text     "subject"
    t.integer  "teaching_id"
    t.decimal  "percentile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vams", ["teaching_id"], name: "index_vams_on_teaching_id", using: :btree

  create_table "years", force: true do |t|
    t.text     "year"
    t.integer  "ending_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
