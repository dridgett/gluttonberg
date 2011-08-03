module Gluttonberg
 class Stylesheet  < ActiveRecord::Base
   set_table_name "gb_stylesheets"
   include Content::SlugManagement
   is_versioned :non_versioned_columns => ['position']
   
  end
end   