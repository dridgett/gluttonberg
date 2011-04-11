module Gluttonberg
  class ImageContent  < ActiveRecord::Base
    include Content::Block
    set_table_name "gb_image_contents"
    belongs_to :asset
    
    acts_as_versioned  :limit => Rails.configuration.gluttonberg[:number_of_revisions]
    
  end
end