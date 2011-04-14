module Gluttonberg
  module Content
    # A mixin which allows for any arbitrary model to have multiple versions. It will 
    # generate the versioning models and add methods for creating, managing and 
    # retrieving different versions of a record.
    
    module Versioning
      
      def self.setup
        ::ActiveRecord::Base.send :include, Gluttonberg::Content::Versioning
      end
      
      def self.included(klass)
        klass.class_eval do
          extend  ClassMethods
          include InstanceMethods
          
          cattr_reader :versioned
          @@versioned = false
          
        end
      end
      
      module ClassMethods
        def is_versioned(options = {}, &extension)
          acts_as_versioned( options.merge( :limit => Rails.configuration.gluttonberg[:number_of_revisions] ) , &extension )
        end
        
        def versioned?
          versioned
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