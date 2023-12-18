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

ActiveRecord::Schema[7.1].define(version: 2023_12_12_140227) do
  create_table "offices", force: :cascade do |t|
    t.text "municipality"
    t.text "country"
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weathers", primary_key: ["lat", "lon", "dt"], force: :cascade do |t|
    t.integer "office_id"
    t.datetime "dt"
    t.float "lat"
    t.float "lon"
    t.string "name"
    t.string "desc"
    t.float "average_temp"
    t.float "max_temp"
    t.string "min_temp"
    t.string "float"
    t.float "feels_like"
    t.integer "humidity"
    t.integer "pressure"
    t.integer "cloud_cover"
    t.float "wind_speed"
    t.integer "wind_direction"
    t.float "wind_gust"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_weathers_on_office_id"
  end

end
