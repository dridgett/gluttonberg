module Gluttonberg
  class AssetCollection < ActiveRecord::Base
      set_table_name "gb_asset_collections"
      has_and_belongs_to_many :assets, :class_name => "Asset" , :join_table => "gb_asset_collections_assets"
      validates_uniqueness_of :name
      validates_presence_of :name
      
      def images
        data = assets.find(:all , :include => :asset_type )
        data.find_all{|d| d.category == "image"}
      end
      
      # this method is required for gallery form
      def name_with_number_of_images
        "#{name} (#{images.length} images)"
      end
  end
end  