#
#  DragTree is a mix of DataMapper plugin, Merb Plugin and jQuery Plugin
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
#     include DataMapper::Resource
#     # this class is tree and supports parenting
#     property :parent_id, Integer
#     is_drag_tree :scope => [:parent_id], :flat => false
#   end
#
#   class Article
#     include DataMapper::Resource
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
#                  move_node() action added to the controller. If you
#                  are not using auto generation then you must set this to
#                  the route you have created.
#      :auto_gen_route (true|false) default is true. If true a route
#                  will automatically be created to use as the callback
#                  from the jQuery dragTree via AJAX. IF false you
#                  will need to create the route yourself.
#
#    NOTE: You must set :auto_gen_route to false if your are using
#          this in a slice (including Gluttonberg) and ensure you
#          set :route_name to the route you create.
#
#    NOTE: This adds the action :move_node to your controller
#          you may need to exclude this action from your before
#          filters to prevent them running (and possible failing)
#          e.g.
#            before :find_panel, :exclude => [:index, :create, :new, :move_node]
#
#    Example
#
#    class Pages < Gluttonberg::Application
#      # this requires you to manually create the route named :page_move
#      # support for the Page class is added to the controller
#      drag_tree Page, :route_name => :page_move, :auto_gen_route => false
#    end
#
#    class Articles < Application
#      # support for the Article class is added to the controller
#      drag_tree Article
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
      ::Gluttonberg::DragTree::RouteHelpers.build_drag_tree_routes
    end
    
     
    module RouteHelpers
      def self.build_drag_tree_routes#(router)
        ::ActionController::Base.drag_tree_class_list.each do |drag_controller_class|
          #puts "============#{drag_controller_class}"
          #drag_controller_class.add_route_for_drag_tree(router)
        end
      end
    end


    module ModelTracker
      @@_drag_tree_class_list = []
      def self.class_list
        @@_drag_tree_class_list
      end
      def self.register_class(model_class)
        @@_drag_tree_class_list << model_class
      end
    end
    
    
  end #DragTree  
end #Gluttonberg




