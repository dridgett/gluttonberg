module Gluttonberg
  class AudioAssetAttribute < ActiveRecord::Base
      belongs_to :asset
      set_table_name "gb_audio_asset_attributes"
      
  end #class
end   #module  