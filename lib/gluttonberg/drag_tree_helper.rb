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

module Gluttonberg
  module DragTree
    
    
    #-------------------------------------------------ActionController ------------------------------------------
    

    module ActionController
      
      def self.included(base)
           base.extend(ClassMethods)
      end
      
      
      module ClassMethods
          @@_drag_tree_class_list = []
          def drag_tree(model_class, options = {})
            @@_drag_tree_class_list << self
            self.send(:include, Gluttonberg::DragTree::ActionController::ControllerHelperClassMethods)
            self.set_drag_tree(model_class, options)            
          end
          
          def drag_tree_class_list
            @@_drag_tree_class_list
          end
          
      end # class methods
      
        module ControllerHelperClassMethods
          def self.included(klass)
            klass.class_eval do
              @drag_tree_model_class = nil
              @drag_tree_route_name = nil
              @generate_route = true

              def klass.drag_class
                @drag_tree_model_class
              end

              def klass.set_drag_tree(model_class, options = {})
                @drag_tree_route_name = options[:route_name] if options[:route_name]
                @generate_route = options[:auto_gen_route] if options[:auto_gen_route]
                @drag_tree_model_class = model_class
              end

              def klass.add_route_for_drag_tree #(router)
                if @generate_route then
                  # add router for this controllers move_node action
                  url_path_to_match = "/drag_tree/#{self.controller_name}/move_node.json"
                  controller_path_to_use = self.controller_name
                  
                  #if route does not exist create it 
              # if Rails.application.routes.routes.find{|route| route.name == self.drag_tree_route_name }.blank?
              #                     Rails.application.routes.add_route(Rails.application.app, conditions = {}, requirements = { :controller => controller_path_to_use, :action => "move_node" }, defaults = {}, name = nil, anchor = true)
              #                   end
                  #router.match(url_path_to_match).to(:controller => controller_path_to_use, :action => "move_node").name(self.drag_tree_route_name)
                end
              end

              def klass.drag_tree_route_name
                if @drag_tree_route_name then
                  @drag_tree_route_name
                else
                  "#{self.controller_name}/move_node".to_sym
                end
              end

              def move_node

                raise Exception.new('dragtree model class not set') unless self.class.drag_class
                raise Exception.new('dragtree model class does not support drag tree operations') unless self.class.drag_class.respond_to?(:behaves_as_a_drag_tree)

                def source_in_destination_ancestry(source, destination)
                  cur_node = destination
                  if cur_node == source
                    return true
                  end
                  while (cur_node.parent != source)
                    cur_node = cur_node.parent
                    return false if cur_node == nil
                  end
                  true
                end

                @pages = self.class.drag_class.all
                raise ActionController::RoutingError.new("No #{self.class.drag_class} found]") unless @pages && !@pages.empty?
                @mode = params[:mode]
                @source = self.class.drag_class.find(params[:source_page_id])
                @dest   = self.class.drag_class.find(params[:dest_page_id])

                #Merb::ControllerExceptions::BadRequest
                raise ActionController::RoutingError.new("Drag source is nil [#{params[:source_page_id]}]") unless @source
                raise ActionController::RoutingError.new("Drag destination is nil [#{params[:dest_page_id]}]") unless @dest

                if !self.class.drag_class.behaves_as_a_flat_drag_tree
                  if source_in_destination_ancestry(@source, @dest)
                     raise ActionController::RoutingError.new
                  end
                end

                if (@mode == 'INSERT') and @source and @dest and !self.class.drag_class.behaves_as_a_flat_drag_tree
                  # an insert is a reparenting operation. the source becomes the child of the
                  # dest.
                  @source.parent_id = @dest.id
                  ### @source.move :highest
                  @source.move_to_bottom
                  
                  render :json => {:success => true}
                else
                  # if we are inserting after a node and that node has children, we are actually
                  # reparenting to that node

                  do_reparent = false
                  if !self.class.drag_class.behaves_as_a_flat_drag_tree then
                    if (@mode == 'AFTER') and (@dest.children.count > 0) then
                      do_reparent = true
                    end
                  end

                  if do_reparent
                    if (@source.parent_id != @dest.id)
                      @source.parent_id = @dest.id
                      @source.save!
                    end
                    ## @source.move :highest
                    @source.move_to_bottom
                    
                    @source.save!
                    render :json => {:success => true}
                  else

                    if !self.class.drag_class.behaves_as_a_flat_drag_tree
                      # if the pages don't have the same parent, need to reparent
                      # the @source
                      if @source.parent_id != @dest.parent_id
                        @source.parent_id = @dest.parent_id
                        @source.save!
                      end
                    end

                    if @mode == 'AFTER'
                      @source.insert_at @dest.position 
                      #@source.move :below => @dest
                      @source.save!
                      {:success => true}.to_json                    
                    elsif @mode == 'BEFORE'
                      @source.insert_at @dest.position - 1
                      #@source.move :above => @dest
                      @source.save!
                      render :json => {:success => true}
                    else
                      raise Merb::ControllerExceptions::BadRequest.new
                    end
                  end
                end
              end
            end
          end
        end
      
    end

    # -------------------# action view---------------------------------
    
    module ActionView
      module Helpers
        def drag_tree_class_list
          @@_drag_tree_class_list
        end

        def drag_tree_url(klass = self.class)
          
          controller_class = @controller.class
          
          #Rails.application.routes.routes.find{|route| route.name == "admin_page_move"}
          
          #puts "--#{Rails.application.routes.routes.class.to_s}---#{Rails.application.routes.methods}------"
          
          
          if controller_class.respond_to?(:drag_tree_route_name) then
              url_for(controller_class.drag_tree_route_name)
          else
              ''
          end          
        end
        

        def drag_tree_table_class(klass = self.class)
          # drag-tree treeTable
          controller_class = @controller.class
          css_class_str = ''
          if controller_class.respond_to?(:drag_class) then
            if controller_class.drag_class then
              if controller_class.drag_class.respond_to?(:behaves_as_a_drag_tree) then
                css_class_str = 'drag-tree'
                if controller_class.drag_class.behaves_as_a_flat_drag_tree then
                  css_class_str = css_class_str + ' drag-flat'
                end
              end
            end
          end
          css_class_str
        end

        def drag_tree_row_class(model)
          css_class_str = ''
          if model.class.respond_to?(:behaves_as_a_drag_tree) then
            css_class_str = 'node-pos-' + model.position.to_s
            if !model.class.behaves_as_a_flat_drag_tree then
              if model.parent_id then
                css_class_str = css_class_str + ' child-of-node-' + model.parent_id.to_s
              end
            end
          end
          css_class_str
        end

        def drag_tree_drag_point_class
          'drag-node'
        end

        def drag_tree_row_id(model)
          "node-#{model.id}"
        end
        
        
      
      end
    
    end       


      #-------------------------------------------------ActiveRecord ------------------------------------------
  
      module ActiveRecord
        
        def self.included(base)
             base.extend(ClassMethods)
        end
        
        
        module ClassMethods
            
            def is_drag_tree(options = {})
              options[:flat] = true unless options.has_key?(:flat)
              self.send(:include, Gluttonberg::DragTree::ActiveRecord::ModelHelpersClassMethods)
              acts_as_list options
              unless options[:flat]
                acts_as_tree options
              else
                self.make_flat_drag_tree
              end
              ModelTracker.register_class(self)
            end
          
        end #module ClassMethods
        
        module ModelHelpersClassMethods
           def self.included(klass)
            klass.class_eval do
              @is_flat_drag_tree = false
              def klass.behaves_as_a_drag_tree
                true
              end
              def klass.make_flat_drag_tree
                @is_flat_drag_tree = true
              end
              def klass.behaves_as_a_flat_drag_tree
                @is_flat_drag_tree
              end
              def klass.repair_drag_tree
                if behaves_as_a_flat_drag_tree
                  if list_options[:scope].empty?
                    repair_list
                  else
                    # this is wasteful as it does a repair on every item
                    # which means for items of the same scope they keep
                    # getting re-repaired. :-(
                    items = all()
                    items.each{ |item| item.repair_list}
                  end
                end
                # todo: add support for non flat trees
              end
              def klass.all_sorted(query={})
                all({:order => [:position.asc]}.merge(query))
              end
            end
          end
        end
        
        
      end # ActiveRecord

    #-------------------------------------------------End ActiveRecord ------------------------------------------  

    module RouteHelpers
      def self.build_drag_tree_routes#(router)
        ::ActionController::Base.drag_tree_class_list.each do |drag_controller_class|
          puts "============#{drag_controller_class}"
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



ActiveRecord::Base.send :include, Gluttonberg::DragTree::ActiveRecord
ActionController::Base.send  :include, Gluttonberg::DragTree::ActionController

ActionView::Helpers.send :include , Gluttonberg::DragTree::ActionView::Helpers

Gluttonberg::DragTree::RouteHelpers.build_drag_tree_routes
