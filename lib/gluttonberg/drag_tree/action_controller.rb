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
              if params[:element_ids].blank?
                render :json => {:success => false}
                return
              end
              ids = params[:element_ids].split(",")        
              elements = self.class.drag_class.find_by_sorted_ids(ids )        
              elements.each_with_index do |element , index|
                attr = {:position => index + 1  }
                element.update_attributes!( attr   )
              end
              render :json => {:success => true}
            end

          end
        end
      end
  
    end
  end #DragTree
end  # Gluttonberg