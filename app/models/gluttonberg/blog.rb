module Gluttonberg
  class Blog < ActiveRecord::Base
    set_table_name "gb_blogs"
    include Content::Publishable
    include Content::SlugManagement
    
    belongs_to :user
    has_many :articles, :dependent => :destroy
    
    is_versioned :non_versioned_columns => 'state'
  end
end