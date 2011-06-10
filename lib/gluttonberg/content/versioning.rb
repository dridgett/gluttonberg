module Gluttonberg
  module Content
    # A mixin which allows for any arbitrary model to have multiple versions. It will 
    # generate the versioning models and add methods for creating, managing and 
    # retrieving different versions of a record.
    # In reality this is behaving like a wrapper on acts_as_versioned
    module Versioning
      
      def self.setup
        ::ActiveRecord::Base.send :include, Gluttonberg::Content::Versioning
      end
      
      def self.included(klass)
        klass.class_eval do
          extend  ClassMethods
          include InstanceMethods          
        end
      end
      
      module ClassMethods
        
        def is_versioned(options = {}, &extension)
          excluded_columns = options.delete(:non_versioned_columns)
          acts_as_versioned( options.merge( :limit => Gluttonberg::Setting.get_setting("number_of_revisions") ) , &extension )   
          self.non_versioned_columns << excluded_columns 
          self.non_versioned_columns.flatten!
        end
        
        def versioned?
          self.respond_to?(:versioned_class_name)
        end
        
      end
      
      module InstanceMethods
        def versioned?
          self.class.versioned?
        end
      end
      
    end
  end
end  