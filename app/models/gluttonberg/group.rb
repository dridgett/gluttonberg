module Gluttonberg
  class Group < ActiveRecord::Base
    is_drag_tree :flat => true , :order => "position"
    set_table_name "gb_groups"
  end
end