module Gluttonberg
  module DragTree
    module ActionController
  
      def self.included(base)
           base.extend(ClassMethods)
      end
  
  
      module ClassMethods
        def drag_tree(model_class, options = {})
          self.send(:include, Gluttonberg::DragTree::ActionController::ControllerHelperClassMethods)
          self.set_drag_tree(model_class, options)            
        end
    
      end # class methods
  
      module ControllerHelperClassMethods
        def self.included(klass)
          klass.class_eval do
            @drag_tree_model_class = nil
            @drag_tree_route_name = nil

            def klass.drag_class
              @drag_tree_model_class
            end

            def klass.set_drag_tree(model_class, options = {})
              @drag_tree_route_name = options[:route_name] if options[:route_name]
              @drag_tree_model_class = model_class
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
              raise ActiveRecord::RecordNotFound if @pages.blank?
              @mode = params[:mode]
              @source = self.class.drag_class.find(params[:source_page_id])
              @dest   = self.class.drag_class.find(params[:dest_page_id])

              raise ActiveRecord::RecordNotFound.new("Drag source is nil [#{params[:source_page_id]}]") unless @source
              raise ActiveRecord::RecordNotFound.new("Drag destination is nil [#{params[:dest_page_id]}]") unless @dest

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
                    @source.insert_at( @dest.position + 1 ) #+ 1
                    #@source.move :below => @dest
                    @source.save!
                    render :json => {:success => true}                    
                  elsif @mode == 'BEFORE'
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