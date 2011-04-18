module Gluttonberg
  class Article < ActiveRecord::Base
    set_table_name "gb_articles"
    
    belongs_to :blog
    
  end
end