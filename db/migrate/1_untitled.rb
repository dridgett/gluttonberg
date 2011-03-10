# SQLEditor export: Rails Migration
# id columns are removed
class Untitled < ActiveRecord::Migration 
  def self.up
    create_table :gb_dialects do |t|
      t.column :code, :string, :limit => 15, :null => false
      t.column :name, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
      t.column :user_id, :integer
    end

    create_table :gb_rich_text_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_localization_id, :integer
      t.column :text, :text
      t.column :formatted_text, :text
      t.column :rich_text_content_id, :integer
    end

    #gb_dialects_gb_locales
    create_table :dialects_locales , :id => false do |t|
      t.column :locale_id, :integer, :null => false
      t.column :dialect_id, :integer, :null => false
    end

    create_table :gb_plain_text_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_localization_id, :integer
      t.column :text, :string, :limit => 255
      t.column :plain_text_content_id, :integer
    end

    create_table :gb_html_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

    create_table :gb_html_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :text, :text
      t.column :html_content_id, :integer
      t.column :page_localization_id, :integer
    end

    create_table :gb_image_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :asset_id, :integer
      t.column :page_id, :integer
    end

    create_table :gb_users do |t|
      t.column :crypted_password, :string, :limit => 50
      t.column :salt, :string, :limit => 50
      t.column :name, :string, :limit => 100
      t.column :email, :string, :limit => 100
      t.column :is_super_admin, :boolean, :default => true
    end

    create_table :gb_locales do |t|
      t.column :name, :string, :limit => 70, :null => false
      t.column :slug, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
      t.column :locale_id, :integer
      t.column :user_id, :integer
    end

    create_table :gb_settings do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :value, :text
      t.column :category, :integer, :default => 1
      t.column :row, :integer
      t.column :delete_able, :boolean, :default => true
      t.column :enabled, :boolean, :default => true
      t.column :help, :text
    end

    create_table :gb_page_localizations do |t|
      t.column :name, :string, :limit => 150
      t.column :navigation_label, :string, :limit => 100
      t.column :slug, :string, :limit => 50
      t.column :path, :string, :limit => 255
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :dialect_id, :integer
      t.column :locale_id, :integer
      t.column :page_id, :integer
    end

    create_table :gb_rich_text_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

    create_table :gb_pages do |t|
      t.column :parent_id, :integer
      t.column :name, :string, :limit => 100
      t.column :navigation_label, :string, :limit => 100
      t.column :slug, :string, :limit => 100
      t.column :description_name, :string, :limit => 100
      t.column :home, :boolean, :default => false
      t.column :depth, :integer, :default => 0
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :position, :integer
      #t.column :page_id, :integer
      t.column :user_id, :integer
    end

    create_table :gb_plain_text_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

  end

  def self.down
    drop_table :gb_dialects
    drop_table :gb_rich_text_content_localizations
    drop_table :gb_dialects_gb_locales
    drop_table :gb_plain_text_content_localizations
    drop_table :gb_html_contents
    drop_table :gb_html_content_localizations
    drop_table :gb_image_contents
    drop_table :gb_users
    drop_table :gb_locales
    drop_table :gb_settings
    drop_table :gb_page_localizations
    drop_table :gb_rich_text_contents
    drop_table :gb_pages
    drop_table :gb_plain_text_contents
  end
end
