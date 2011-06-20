module Gluttonberg
  class AssetThumbnail  < ActiveRecord::Base
    belongs_to :asset
    set_table_name "gb_asset_thumbnails"
    
  end
end