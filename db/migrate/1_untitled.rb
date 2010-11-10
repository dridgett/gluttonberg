# SQLEditor export: Rails Migration
# id columns are removed
class Untitled < ActiveRecord::Migration 
  def self.up
    create_table :dialects do |t|
      t.column :code, :string, :limit => 15, :null => false
      t.column :name, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
      t.column :user_id, :integer
    end

    create_table :rich_text_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_localization_id, :integer
      t.column :text, :text
      t.column :formatted_text, :text
      t.column :rich_text_content_id, :integer
    end

    create_table :dialects_locales, :id => false do |t|
      t.column :locale_id, :integer, :null => false
      t.column :dialect_id, :integer, :null => false
    end

    create_table :plain_text_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_localization_id, :integer
      t.column :text, :string, :limit => 255
      t.column :plain_text_content_id, :integer
    end

    create_table :html_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

    create_table :html_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :text, :text
      t.column :html_content_id, :integer
      t.column :page_localization_id, :integer
    end

    create_table :image_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :asset_id, :integer
      t.column :page_id, :integer
    end

    create_table :users do |t|
      t.column :crypted_password, :string, :limit => 50
      t.column :salt, :string, :limit => 50
      t.column :name, :string, :limit => 100
      t.column :email, :string, :limit => 100
      t.column :is_super_admin, :boolean, :default => true
    end

    create_table :locales do |t|
      t.column :name, :string, :limit => 70, :null => false
      t.column :slug, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
      t.column :locale_id, :integer
      t.column :user_id, :integer
    end

    create_table :settings do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :value, :text
      t.column :category, :integer, :default => 1
      t.column :row, :integer
      t.column :delete_able, :boolean, :default => true
      t.column :enabled, :boolean, :default => true
      t.column :help, :text
    end

    create_table :page_localizations do |t|
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

    create_table :rich_text_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

    create_table :pages do |t|
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

    create_table :plain_text_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end

  end

  def self.down
    drop_table :Dialects
    drop_table :richTextContentLocalizations
    drop_table :DialectsGluttonbergLocales
    drop_table :plainTextContentLocalizations
    drop_table :HtmlContents
    drop_table :htmlContentLocalizations
    drop_table :ImageContents
    drop_table :Users
    drop_table :Locales
    drop_table :Settings
    drop_table :PageLocalizations
    drop_table :RichTextContents
    drop_table :Pages
    drop_table :PlainTextContents
  end
end
