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

ActiveRecord::Schema[8.0].define(version: 2026_01_29_144823) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "profiles", force: :cascade do |t|
    t.string "name", null: false
    t.string "github_url", null: false
    t.string "short_github_url"
    t.string "github_username"
    t.integer "followers"
    t.integer "following"
    t.integer "stars"
    t.integer "contributions_last_year"
    t.string "avatar_url"
    t.string "location"
    t.jsonb "organizations", default: []
    t.datetime "last_scraped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scrape_status", default: 0, null: false
    t.index ["github_username"], name: "index_profiles_on_github_username"
    t.index ["organizations"], name: "index_profiles_on_organizations", using: :gin
  end
end
