module Gluttonberg
  class Blog < ActiveRecord::Base
    set_table_name "gb_blogs"
    include Content::Publishable
    include Content::SlugManagement
    
    belongs_to :user
    has_many :articles, :dependent => :destroy
        
  end
end