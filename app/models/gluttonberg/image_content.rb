module Gluttonberg
  class ImageContent  < ActiveRecord::Base
    
    set_table_name "gb_image_contents"
        
    belongs_to :asset
  end
end