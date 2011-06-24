module Gluttonberg
  module DragTree    
    module ActiveRecord
        
      def self.included(base)
         base.extend(ClassMethods)
      end
        
        
      module ClassMethods                  
        def is_drag_tree(options = {})
          options[:flat] = true unless options.has_key?(:flat)
          self.send(:include, Gluttonberg::DragTree::ActiveRecord::ModelHelpersClassMethods)
          if options.has_key?(:scope)
            acts_as_list :scope => options[:scope]
          else
            acts_as_list
          end
          unless options[:flat]
            acts_as_tree options
          else
            self.make_flat_drag_tree
          end
        end
        
        def repair_list(list)
          unless list.blank?
            list.each_with_index do |sibling , index|
              sibling.position = index
              sibling.save
            end
          end  
        end
        
        def find_by_sorted_ids(new_sorted_element_ids)
          # find records in unorder list
          elements = self.find(new_sorted_element_ids )
          # sort it using ruby method
          sorted_elements = []        
          new_sorted_element_ids.each do |id|
            id = id.to_i
            sorted_elements << elements.find{ |x| x.id == id }          
          end
          sorted_elements
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
          end # class_eval
        end #included
      end #ModelHelpersClassMethods
        
        
    end # ActiveRecord
    
    
    
    
  end #DragTree
end  #Gluttonberg