module Gluttonberg
  class GalleryImage < ActiveRecord::Base
    set_table_name "gb_gallery_images"
    belongs_to :gallery
    belongs_to :image  , :class_name => "Gluttonberg::Asset" , :foreign_key => "asset_id"
    is_drag_tree :scope => :gallery_id , :flat => true , :order => "position"
  end
end