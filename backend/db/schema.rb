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

ActiveRecord::Schema[7.2].define(version: 2025_06_08_083554) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string "country_code"
    t.string "icao_code", null: false
    t.string "label"
    t.float "lat"
    t.float "lon"
    t.string "uri"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["icao_code"], name: "index_airports_on_icao_code", unique: true
  end

  create_table "tracks", force: :cascade do |t|
    t.datetime "timestamp"
    t.string "flight_id"
    t.float "lat"
    t.float "lon"
    t.integer "alt"
    t.string "aircraft_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timestamp", "flight_id"], name: "index_tracks_on_timestamp_and_flight_id", unique: true
  end
end
