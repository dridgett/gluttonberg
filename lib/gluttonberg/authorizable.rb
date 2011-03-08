module Gluttonberg  
    # A mixin that will add simple authorization functionality to any arbitrary 
    # model. This includes finders for retrieving authorized records and 
    # instance methods for quickly changing the state.
    module Authorizable
      # Add the class and instance methods, declare the relationship we store the
      # published state in.
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
          
          belongs_to :user , :class_name => "Gluttonberg::User"
        end
      end

      module ClassMethods
        
        # Returns all matching records that are authorize to provided user. 
        # For Super admin users returns all records
        # For other non-super-users checks th condition of user_id
        # May be called with additional conditions.
        def all_for_user(user , options = {})
          if user.is_super_admin
            all(options)
          else
            options[:user_id] = user.id
            all(options)
          end
        end  
        
        # Returns first matching records that is authorize to provided user with given id. 
        # For Super admin users it checks only id but for non-super-users checks additionally it checks condition of user_id
        
        def get_for_user(user , id)
          options = {:id => id }
          if user.is_super_admin            
            first(options)
          else
            options[:user_id] = user.id
            first(options)
          end
        end  
      end  #ClassMethods

      module InstanceMethods
        
      end #InstanceMethods
      
    end # Authorizable  
end # Gluttonberg
