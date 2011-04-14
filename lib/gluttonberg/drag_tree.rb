#
#  DragTree is a mix of ActiveRecord plugin, Rails Plugin and jQuery Plugin
#  It provides a simple way of defining a Model that is ordered (and optionally a tree)
#  and have the ability to simply provide an Ajax table/tree to reorganise
#  the order and parenting.
#
#  To get started you need to declare in your DataMapper class is_drag_tree
#
#  format:
#    is_drag_tree(options)
#
#    options:
#       :flat (true|false) default is true. If true the class supports
#             reordering, but not parenting, i.e. is NOT a tree.
#
#      Options is passed through to the is_list and is_tree DataMapper
#      declarations.
#
#  Examples:
#
#   class Page
#     is_drag_tree :scope => :parent_id, :flat => false
#   end
#
#   class Article
#     # this class is a flat table
#     is_drag_tree
#   end
#
#  Then in your controller for that class add the drag_tree declaration
#
#  format:
#    drag_tree(class, options)
#
#    class: The DataMapper Model class of that has the is_drag_tree declaration.
#
#    options:
#      :route_name (symbol) This is the name of the route used to access the
#                  move_node() action added to the controller. You must set this to
#                  the route you have created.
#     
#
#    NOTE: This adds the action :move_node to your controller
#          you may need to exclude this action from your before
#          filters to prevent them running (and possible failing)
#          e.g.
#            before_filter :find_panel, :exclude => [:index, :create, :new, :move_node]
#
#    Example
#
#    class PagesController < Gluttonberg::Application
#      # this requires you to manually create the route named :page_move
#      # support for the Page class is added to the controller
#      drag_tree Page, :route_name => :page_move
#    end
#
#    class ArticlesController < Application
#      # support for the Article class is added to the controller
#      # this requires you to manually create the route named :article_move    
#      drag_tree Article , :route_name => :article_move
#    end
#
#    To now render this is a view you need to use the following view helpers:
#
#      drag_tree_url
#          This returns the url required for the callback from the clientside
#          javascript. This should be placed in the rel tag of the table. If
#          you are calling this from within a slice use the drag_tree_slice_url
#          call instead.
#
#
#      drag_tree_table_class
#          this returns the css classes required for the table tag. Classes are
#          returned as a space delimited string.
#
#      drag_tree_row_class(model)
#          this returns the css classes required for the row. The <model> parameter
#          is the instance of the DataMapper class for this row. Classes are
#          returned as a space delimited string.
#
#      drag_tree_drag_point_class
#          this returns the css classes required for the tag that will be used
#          as the drag point. Generally this is a <span> tag within the first
#          cell of each row. Classes are returned as a space delimited string.
#
#      drag_tree_row_id(model)
#          this returns the css id required for a row. The <model> parameter
#          is the instance of the DataMapper class for this row. A string is
#          returned.
#
#    (Examples in HAML)
#
#      %table{:class => drag_tree_table_class, :cellpadding => 0, :cellspacing => 0, :rel => drag_tree_url, :summary => "Drag Tree Table"}
#        - for article in @articles
#          %tr{:id => drag_tree_row_id(article), :class => drag_tree_row_class(article)}
#            %td
#              %span{:class => drag_tree_drag_point_class}
#                = h(article.title)
#            %td
#              = h(article.content)
#


lib = Pathname(__FILE__).dirname.expand_path
require File.join(lib, "drag_tree", "action_controller")
require File.join(lib, "drag_tree", "action_view")
require File.join(lib, "drag_tree", "active_record")


module Gluttonberg
  module DragTree
    def self.setup
      ::ActiveRecord::Base.send :include, Gluttonberg::DragTree::ActiveRecord
      ::ActionController::Base.send  :include, Gluttonberg::DragTree::ActionController
      ::ActionView::Helpers.send :include , Gluttonberg::DragTree::ActionView::Helpers      
    end
  end #DragTree  
end #Gluttonberg




