module Gluttonberg
  class Blog < ActiveRecord::Base
    set_table_name "gb_blogs"
    include Content::Publishable
    include Content::SlugManagement
    
    belongs_to :user
    has_many :articles, :dependent => :destroy
    
    validates_presence_of :name
    
    is_versioned :non_versioned_columns => 'state'
    
    acts_as_taggable_on :tag
  end
end