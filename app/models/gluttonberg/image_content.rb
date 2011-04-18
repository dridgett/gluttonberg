module Gluttonberg
  class ImageContent  < ActiveRecord::Base
    include Content::Block
    set_table_name "gb_image_contents"
    belongs_to :asset
    
    is_versioned
    
  end
end