class GluttonbergMigration < ActiveRecord::Migration 
  def self.up
    
    create_table :gb_dialects do |t|
      t.column :code, :string, :limit => 15, :null => false
      t.column :name, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
      t.column :user_id, :integer
    end


    create_table :gb_dialects_locales , :id => false do |t|
      t.column :locale_id, :integer, :null => false
      t.column :dialect_id, :integer, :null => false
    end

    create_table :gb_plain_text_content_localizations do |t|
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_localization_id, :integer
      t.column :text, :string, :limit => 255
      t.column :plain_text_content_id, :integer
      t.column :version, :integer
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
      t.column :version, :integer
    end

    create_table :gb_image_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :asset_id, :integer
      t.column :page_id, :integer
      t.column :version, :integer
    end


    create_table :gb_locales do |t|
      t.column :name, :string, :limit => 70, :null => false
      t.column :slug, :string, :limit => 70, :null => false
      t.column :default, :boolean, :default => false
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
      t.column :values_list, :text
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

    
    create_table :gb_pages do |t|
      t.column :parent_id, :integer
      t.column :name, :string, :limit => 100
      t.column :navigation_label, :string, :limit => 100
      t.column :slug, :string, :limit => 100
      t.column :description_name, :string, :limit => 100
      t.column :home, :boolean, :default => false
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :position, :integer
      t.column :user_id, :integer
      t.column :state , :string
    end

    create_table :gb_plain_text_contents do |t|
      t.column :orphaned, :boolean, :default => false
      t.column :section_name, :string, :limit => 50
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :page_id, :integer
    end
    
    create_table :gb_asset_categories do |t|
      t.column :name, :string, :null => false
      t.column :unknown, :boolean
    end

    create_table :gb_asset_types do |t|
      t.column :name, :string, :null => false
      t.column :asset_category_id, :integer, :default => 0
    end
    
    create_table :gb_asset_mime_types do |t|
      t.column :mime_type, :string, :null => false
      t.column :asset_type_id, :integer, :default => 0
    end
    
    create_table :gb_asset_collections do |t|
      t.column :name, :string, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :updated_by, :integer      
    end
        
    create_table :gb_assets do |t|
      t.column :mime_type, :string
      t.column :asset_type_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :file_name, :string
      t.column :asset_hash, :string
      t.column :size, :integer
      t.column :custom_thumbnail, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :synopsis, :text
      t.column :copyrights, :text
      t.column :year_of_production, :integer
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.column :duration, :string
    end
    
    create_table :gb_audio_asset_attributes do |t|
      t.integer :asset_id , :null => false      
      t.float   :length           
      t.string  :title 
      t.string  :artist
      t.string  :album
      t.string  :tracknum
      t.string  :genre
      t.timestamps
    end
    
    create_table :gb_asset_collections_assets , :id => false do |t|
      t.column :asset_collection_id, :integer, :null => false
      t.column :asset_id, :integer, :null => false
    end
    
    create_table :gb_users do |t|
      t.string :email, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.string :single_access_token, :null => false
      t.string :perishable_token, :null => false
      t.integer :login_count, :null => false, :default => 0
      t.timestamps
    end
    
    
    begin
      Gluttonberg::PlainTextContentLocalization.create_versioned_table
    rescue => e
      puts e
    end
    begin
      Gluttonberg::HtmlContentLocalization.create_versioned_table
    rescue => e
      puts e
    end
         
  end

  def self.down
    drop_table :gb_dialects
    drop_table :gb_dialects_locales
    drop_table :gb_plain_text_content_localizations
    drop_table :gb_html_contents
    drop_table :gb_html_content_localizations
    drop_table :gb_image_contents
    drop_table :gb_users
    drop_table :gb_locales
    drop_table :gb_settings
    drop_table :gb_page_localizations
    drop_table :gb_pages
    drop_table :gb_plain_text_contents
    drop_table :gb_asset_categories
    drop_table :gb_asset_types
    drop_table :gb_asset_mime_types
    drop_table :gb_asset_collections
    drop_table :gb_assets
    drop_table :gb_asset_collections_assets
    drop_table :gb_audio_asset_attributes
  end
end
