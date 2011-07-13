module Gluttonberg
  class AssetMimeType < ActiveRecord::Base
      set_table_name "gb_asset_mime_types"
      belongs_to :asset_type, :class_name => "AssetType"
      validates_uniqueness_of :mime_type
  end
end