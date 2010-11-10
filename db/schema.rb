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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101110061505) do

  create_table "dialects", :force => true do |t|
    t.string  "code",    :limit => 15,                    :null => false
    t.string  "name",    :limit => 70,                    :null => false
    t.boolean "default",               :default => false
    t.integer "user_id"
  end

  create_table "dialects_locales", :id => false, :force => true do |t|
    t.integer "locale_id",  :null => false
    t.integer "dialect_id", :null => false
  end

  create_table "html_content_localizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text"
    t.integer  "html_content_id"
    t.integer  "page_localization_id"
  end

  create_table "html_contents", :force => true do |t|
    t.boolean  "orphaned",                   :default => false
    t.string   "section_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
  end

  create_table "image_contents", :force => true do |t|
    t.boolean  "orphaned",                   :default => false
    t.string   "section_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "asset_id"
    t.integer  "page_id"
  end

  create_table "locales", :force => true do |t|
    t.string  "name",      :limit => 70,                    :null => false
    t.string  "slug",      :limit => 70,                    :null => false
    t.boolean "default",                 :default => false
    t.integer "locale_id"
    t.integer "user_id"
  end

  create_table "page_localization_versions", :force => true do |t|
    t.integer  "page_localization_id"
    t.integer  "version"
    t.string   "name",                 :limit => 150
    t.string   "navigation_label",     :limit => 100
    t.string   "slug",                 :limit => 50
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dialect_id"
    t.integer  "locale_id"
    t.integer  "page_id"
  end

  add_index "page_localization_versions", ["page_localization_id"], :name => "index_page_localization_versions_on_page_localization_id"

  create_table "page_localizations", :force => true do |t|
    t.string   "name",             :limit => 150
    t.string   "navigation_label", :limit => 100
    t.string   "slug",             :limit => 50
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dialect_id"
    t.integer  "locale_id"
    t.integer  "page_id"
    t.integer  "version"
  end

  create_table "page_versions", :force => true do |t|
    t.integer  "page_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.string   "name",             :limit => 100
    t.string   "navigation_label", :limit => 100
    t.string   "slug",             :limit => 100
    t.string   "description_name", :limit => 100
    t.boolean  "home",                            :default => false
    t.integer  "depth",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "user_id"
  end

  add_index "page_versions", ["page_id"], :name => "index_page_versions_on_page_id"

  create_table "pages", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name",             :limit => 100
    t.string   "navigation_label", :limit => 100
    t.string   "slug",             :limit => 100
    t.string   "description_name", :limit => 100
    t.boolean  "home",                            :default => false
    t.integer  "depth",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "user_id"
    t.integer  "version"
    t.string   "state"
  end

  create_table "plain_text_content_localizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_localization_id"
    t.string   "text"
    t.integer  "plain_text_content_id"
  end

  create_table "plain_text_contents", :force => true do |t|
    t.boolean  "orphaned",                   :default => false
    t.string   "section_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
  end

  create_table "rich_text_content_localizations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_localization_id"
    t.text     "text"
    t.text     "formatted_text"
    t.integer  "rich_text_content_id"
  end

  create_table "rich_text_contents", :force => true do |t|
    t.boolean  "orphaned",                   :default => false
    t.string   "section_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
  end

  create_table "settings", :force => true do |t|
    t.string  "name",        :limit => 50,                   :null => false
    t.text    "value"
    t.integer "category",                  :default => 1
    t.integer "row"
    t.boolean "delete_able",               :default => true
    t.boolean "enabled",                   :default => true
    t.text    "help"
  end

  create_table "users", :force => true do |t|
    t.string  "crypted_password", :limit => 50
    t.string  "salt",             :limit => 50
    t.string  "name",             :limit => 100
    t.string  "email",            :limit => 100
    t.boolean "is_super_admin",                  :default => true
  end

end
