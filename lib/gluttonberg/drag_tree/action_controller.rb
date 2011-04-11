module Gluttonberg
  module DragTree
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

              puts "-------- step-1"

              @pages = self.class.drag_class.all
              raise ActiveRecord::RecordNotFound if @pages.blank?
              @mode = params[:mode]
              @source = self.class.drag_class.find(params[:source_page_id])
              @dest   = self.class.drag_class.find(params[:dest_page_id])

              #Merb::ControllerExceptions::BadRequest
              raise ActiveRecord::RecordNotFound.new("Drag source is nil [#{params[:source_page_id]}]") unless @source
              raise ActiveRecord::RecordNotFound.new("Drag destination is nil [#{params[:dest_page_id]}]") unless @dest

              puts "-------- step-2"

              if !self.class.drag_class.behaves_as_a_flat_drag_tree
                if source_in_destination_ancestry(@source, @dest)
                  puts "-------- step-3"
                   raise ActionController::RoutingError.new
                   puts "-------- step-4"
                end
              end
              
              puts "-------- step-5"

              if (@mode == 'INSERT') and @source and @dest and !self.class.drag_class.behaves_as_a_flat_drag_tree
                # an insert is a reparenting operation. the source becomes the child of the
                # dest.
                @source.parent_id = @dest.id
                ### @source.move :highest
                @source.move_to_bottom

                puts "-------- step-6"
                
                render :json => {:success => true}
              else
                # if we are inserting after a node and that node has children, we are actually
                # reparenting to that node

                puts "-------- step-7"

                do_reparent = false
                if !self.class.drag_class.behaves_as_a_flat_drag_tree then
                  if (@mode == 'AFTER') and (@dest.children.count > 0) then
                    puts "-------- step-8"
                    do_reparent = true
                  end
                end

                if do_reparent
                  puts "-------- step-9"
                  if (@source.parent_id != @dest.id)
                    @source.parent_id = @dest.id
                    @source.save!
                  end
                  ## @source.move :highest
                  @source.move_to_bottom
              
                  @source.save!
                  render :json => {:success => true}
                else
                  puts "-------- step-10"
                  if !self.class.drag_class.behaves_as_a_flat_drag_tree
                    # if the pages don't have the same parent, need to reparent
                    # the @source
                    if @source.parent_id != @dest.parent_id
                      @source.parent_id = @dest.parent_id
                      @source.save!
                    end
                  end

                  if @mode == 'AFTER'
                    puts "-------- step-11"
                    @source.insert_at( @dest.position + 1 ) #+ 1
                    #@source.move :below => @dest
                    @source.save!
                    render :json => {:success => true}                    
                  elsif @mode == 'BEFORE'
                    puts "-------- step-12  dest position #{@dest.position}   src pos #{@source.position}"
                    @source.insert_at( @dest.position)
                    #@source.move :above => @dest
                    @source.save!
                    render :json => {:success => true}
                  else
                    raise ActiveRecord::RecordNotFound
                  end
                end
              end
            end
          end
        end
      end
  
    end
  end #DragTree
end  # Gluttonberg