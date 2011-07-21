module Gluttonberg
  class Group < ActiveRecord::Base
    is_drag_tree :flat => true , :order => "position"
    set_table_name "gb_groups"
    has_and_belongs_to_many :members, :class_name => "Member" , :join_table => "gb_groups_members"
    has_and_belongs_to_many :pages, :class_name => "Gluttonberg::Page" , :join_table => "gb_groups_pages"
    
    def self.default_group
      self.where(:default =>  true).first
    end
    
  end
end