module Gluttonberg
  class AssetMimeType < ActiveRecord::Base
    
      belongs_to :asset_type, :class_name => "AssetType"
      validates_uniqueness_of :mime_type
    

  end
end