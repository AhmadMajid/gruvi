# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_10_210845) do
  create_table "api_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "url"
    t.index ["url"], name: "index_api_requests_on_url", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "overview"
    t.float "popularity"
    t.string "poster_path"
    t.date "release_date"
    t.integer "revenue"
    t.string "title"
    t.integer "tmdb_id"
    t.datetime "updated_at", null: false
    t.float "vote_average"
    t.integer "vote_count"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "search_results", force: :cascade do |t|
    t.integer "api_request_id", null: false
    t.datetime "created_at", null: false
    t.integer "movie_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["api_request_id"], name: "index_search_results_on_api_request_id"
    t.index ["movie_id"], name: "index_search_results_on_movie_id"
  end

  add_foreign_key "search_results", "api_requests"
  add_foreign_key "search_results", "movies"
end
