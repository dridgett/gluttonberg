class AudioAssets < ActiveRecord::Migration
  def self.up
    create_table :audio_asset_attributes do |t|
      t.integer :asset_id , :null => false      
      t.float   :length           
      t.string  :title 
      t.string  :artist
      t.string  :album
      t.string  :tracknum
      t.string  :genre
      t.timestamps
    end
  end

  def self.down
    drop_table :audio_asset_attributes
  end
end
