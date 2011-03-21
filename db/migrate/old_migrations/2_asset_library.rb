class AssetLibrary < ActiveRecord::Migration
  def self.up
   
   

    
    create_table :gb_asset_categories do |t|
      t.column :name, :string, :null => false
      t.column :unknown, :boolean
    end

    create_table :gb_asset_types do |t|
      t.column :name, :string, :null => false
      t.column :asset_category_id, :integer, :default => 0
      #t.index :asset_category_id
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
      #t.column :type, :string
      t.column :duration, :string
      #t.index :asset_type_id
      # t.index :id
      #       t.index :type
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
    
    create_table :asset_collections_assets , :id => false do |t|
      t.column :asset_collection_id, :integer, :null => false
      t.column :asset_id, :integer, :null => false
      #t.index :asset_id
    end
        
    


  end

  def self.down
    drop_table :gb_asset_categories
    drop_table :gb_asset_types
    drop_table :gb_asset_mime_types
    drop_table :gb_asset_collections
    drop_table :gb_assets
    drop_table :asset_collections_assets
    drop_table :gb_audio_asset_attributes
  end
end
