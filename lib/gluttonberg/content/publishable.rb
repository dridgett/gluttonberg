module Gluttonberg
  module Content
    # A mixin that will add simple publishing functionality to any arbitrary 
    # model. This includes finders for retrieving published records and 
    # instance methods for quickly changing the state.
    module Publishable
      # Add the class and instance methods, declare the property we store the
      # published state in.
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
          
          property :published,  DataMapper::Types::Boolean, :default => false
        end
      end

      module ClassMethods
        
        # Returns the first matching record that is not published. May be called 
        # with additional conditions.
        def unpublished(options = {})
          options[:published] = false
          first(options)
        end
        
        # Returns the first matching record that is published. May be called 
        # with additional conditions.
        def published(options = {})
          options[:published] = true
          first(options)
        end
      
        # Returns all matching records that are published. May be called 
        # with additional conditions.
        def all_published(options = {})
          options[:published] = true
          all(options)
        end
        
        # Returns all matching records that are published for a particular user. May be called 
        # with additional conditions.
        def all_published_for_user( user , options = {})
          options[:published] = true
          options[:user_id] = user.id unless user.is_super_admin        
          all(options)
        end
        
        # Returns all matching records that are published. May be called 
        # with additional conditions.
        def all_unpublished(options = {})
          options[:published] = false
          all(options)
        end
        
        # Returns all matching records that are published for a particular user. May be called 
        # with additional conditions.
        def all_unpublished_for_user( user , options = {})
          options[:published] = false
          options[:user_id] = user.id unless user.is_super_admin        
          all(options)
        end
        
      end

      module InstanceMethods
        # Change the publish state to true and save the record.
        def publish!
          update_attributes(:published=>true)
        end
        
        # Change the publish state to false and save the record.
        def unpublish!
          update_attributes(:published=>false)
        end
        
        # Check to see if this record has been published.
        def published?
          @published
        end
      end
    end # Publishable
  end # Content
end # Gluttonberg
